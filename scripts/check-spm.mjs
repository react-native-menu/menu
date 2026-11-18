#!/usr/bin/env node

/**
 * Checks on the SwiftPM package that no build in this repository performs.
 *
 * `Package.swift` is only resolvable from React Native's SwiftPM autolinking
 * layout (`<app>/ios/build/generated/autolinking/libs/<pkg>`), where its two
 * local dependencies -- `../../../../xcframeworks` and `../../../ios` -- exist.
 * The React Native version this repo pins has no SwiftPM autolinking, so
 * nothing here can build the package end to end. Two invariants can still be
 * verified without that graph:
 *
 *   sources  every native source CocoaPods compiles is in a SwiftPM target too,
 *            and nothing outside ios/ and spm-support/ leaks into one
 *   headers  spm-headers/react_native_menu-Swift.h still mirrors the Swift API
 *            that ios/NewArch/MenuView.mm reaches through it
 *
 * Run with `yarn spm:check`. The source check needs a Swift toolchain; without
 * one it is skipped and the header check still runs.
 */

import { execFileSync } from "node:child_process";
import { readFileSync } from "node:fs";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const repoRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..");

const PROTOCOL_NAME = "FabricViewImplementationProtocol";
const PROTOCOL_SOURCE = "ios/NewArch/FabricViewImplementationProtocol.swift";
const MIRRORED_HEADER = "spm-headers/react_native_menu-Swift.h";
const BRIDGING_HEADER = "ios/Menu-Bridging-Header.h";

/** Swift types the mirrored header is allowed to translate, and how. */
const TYPE_MAP = new Map([
	[
		"[NSDictionary]?",
		{ objc: "NSArray<NSDictionary *> *", attributes: ["copy", "nullable"] },
	],
	["NSString?", { objc: "NSString *", attributes: ["strong", "nullable"] }],
	["Bool", { objc: "BOOL", attributes: [] }],
	["UIEdgeInsets", { objc: "UIEdgeInsets", attributes: [] }],
	[
		"((String) -> Void)?",
		{ objc: "void (^)(NSString *)", attributes: ["copy", "nullable"] },
	],
	[
		"(() -> Void)?",
		{ objc: "void (^)(void)", attributes: ["copy", "nullable"] },
	],
]);

const failures = [];
const notes = [];

function fail(check, message) {
	failures.push(`${check}: ${message}`);
}

function read(relativePath) {
	return readFileSync(join(repoRoot, relativePath), "utf8");
}

function squash(text) {
	return text.replace(/\s+/g, " ").trim();
}

/**
 * Tracked files under `relativeDir`, repo-relative, skipping Xcode projects.
 * Tracked rather than on-disk: build output under ios/ (a consumer's stale
 * codegen, say) is not something either build system should be compiling.
 */
function tracked(relativeDir) {
	const listed = execFileSync("git", ["ls-files", "-z", "--", relativeDir], {
		cwd: repoRoot,
		encoding: "utf8",
	});
	return listed
		.split("\0")
		.filter((path) => path !== "" && !path.includes(".xcodeproj/"));
}

/**
 * The podspec globs `ios/**` + `*.{h,m,mm,swift}`, so CocoaPods compiles every
 * native source in the tree. SwiftPM lists its sources by hand, which is how a
 * file can end up in one build system and not the other.
 */
function checkSources() {
	let described;
	try {
		described = execFileSync(
			"swift",
			["package", "describe", "--type", "json"],
			{
				cwd: repoRoot,
				encoding: "utf8",
				stdio: ["ignore", "pipe", "pipe"],
			},
		);
	} catch (error) {
		if (error.code === "ENOENT") {
			notes.push(
				"sources: skipped, no `swift` on PATH (CI runs this check on macOS)",
			);
			return;
		}
		// A non-zero exit is the manifest failing to evaluate, which is itself
		// the thing worth catching -- SwiftPM would fail the same way.
		fail(
			"sources",
			`\`swift package describe\` failed:\n${error.stderr || error.message}`,
		);
		return;
	}

	const native = tracked("ios").filter((path) => path !== BRIDGING_HEADER);
	const expected = new Map([
		[
			"react_native_menu",
			[
				...native.filter((path) => path.endsWith(".swift")),
				...tracked("spm-support").filter((path) => path.endsWith(".swift")),
			].sort(),
		],
		[
			"ReactNativeMenuObjC",
			native.filter((path) => /\.(m|mm)$/.test(path)).sort(),
		],
	]);

	const targets = new Map(
		JSON.parse(described).targets.map((target) => [
			target.name,
			[...(target.sources ?? [])].sort(),
		]),
	);

	for (const [name, want] of expected) {
		const got = targets.get(name);
		if (!got) {
			fail(
				"sources",
				`Package.swift no longer declares a target named ${name}`,
			);
			continue;
		}
		for (const path of want) {
			if (!got.includes(path)) {
				fail(
					"sources",
					`${path} is compiled by CocoaPods but not by SwiftPM target ${name}`,
				);
			}
		}
		for (const path of got) {
			if (!want.includes(path)) {
				fail(
					"sources",
					`SwiftPM target ${name} compiles ${path}, which is not a tracked source`,
				);
			}
		}
	}
}

/** `var name: Type { get set }` members of the Swift protocol, in order. */
function parseSwiftProtocol(source) {
	const body = source.match(
		new RegExp(`protocol\\s+${PROTOCOL_NAME}\\s*\\{([\\s\\S]*?)\\n\\}`),
	);
	if (!body) return null;
	const members = [];
	const pattern =
		/^[ \t]*(@objc\s+optional\s+)?var\s+(\w+)\s*:\s*(.+?)\s*\{\s*get\s+set\s*\}/gm;
	for (const match of body[1].matchAll(pattern)) {
		members.push({
			name: match[2],
			swiftType: match[3],
			optional: Boolean(match[1]),
		});
	}
	return members;
}

/** `@property` declarations of the mirrored `@protocol`, split on `@optional`. */
function parseMirroredProtocol(header) {
	const body = header.match(
		new RegExp(`@protocol\\s+${PROTOCOL_NAME}([\\s\\S]*?)@end`),
	);
	if (!body) return null;
	const optionalFrom = body[1].indexOf("@optional");
	const members = [];
	for (const match of body[1].matchAll(/@property\s*\(([^)]*)\)\s*([^;]+);/g)) {
		const attributes = match[1].split(",").map((attribute) => attribute.trim());
		const declaration = squash(match[2]);
		// Block properties carry their name inside `(^name)`; everything else
		// ends with it.
		const block = declaration.match(/\(\s*\^\s*(\w+)\s*\)/);
		const name = block ? block[1] : declaration.match(/(\w+)\s*$/)?.[1];
		const objc = block
			? squash(declaration.replace(block[0], "(^)"))
			: squash(declaration.slice(0, declaration.lastIndexOf(name)));
		members.push({
			name,
			objc,
			attributes,
			optional: optionalFrom !== -1 && match.index > optionalFrom,
		});
	}
	return members;
}

/**
 * `ios/NewArch/MenuView.mm` talks to the Swift classes through this header
 * whenever Xcode's generated one is not on the search path -- which is the
 * SwiftPM case. A member added to the Swift protocol and not mirrored here
 * compiles fine under CocoaPods and breaks every SwiftPM consumer.
 */
function checkMirroredHeader() {
	const header = read(MIRRORED_HEADER);
	const swiftMembers = parseSwiftProtocol(read(PROTOCOL_SOURCE));
	const mirrored = parseMirroredProtocol(header);

	if (!swiftMembers) {
		fail(
			"headers",
			`could not find \`protocol ${PROTOCOL_NAME}\` in ${PROTOCOL_SOURCE}`,
		);
		return;
	}
	if (!mirrored) {
		fail(
			"headers",
			`could not find \`@protocol ${PROTOCOL_NAME}\` in ${MIRRORED_HEADER}`,
		);
		return;
	}

	const byName = new Map(mirrored.map((member) => [member.name, member]));
	for (const member of swiftMembers) {
		const found = byName.get(member.name);
		byName.delete(member.name);
		if (!found) {
			fail(
				"headers",
				`${PROTOCOL_NAME}.${member.name} is not mirrored in ${MIRRORED_HEADER}`,
			);
			continue;
		}
		const translation = TYPE_MAP.get(member.swiftType);
		if (!translation) {
			fail(
				"headers",
				`${member.name} has Swift type \`${member.swiftType}\`, which this check cannot ` +
					`translate -- add it to TYPE_MAP once you have mirrored it by hand`,
			);
			continue;
		}
		if (found.objc !== translation.objc) {
			fail(
				"headers",
				`${member.name} is \`${member.swiftType}\` in Swift but \`${found.objc}\` in the header ` +
					`(expected \`${translation.objc}\`)`,
			);
		}
		for (const attribute of translation.attributes) {
			if (!found.attributes.includes(attribute)) {
				fail(
					"headers",
					`${member.name} is missing the \`${attribute}\` property attribute`,
				);
			}
		}
		if (found.optional !== member.optional) {
			const where = member.optional ? "after" : "before";
			fail(
				"headers",
				`${member.name} should be declared ${where} \`@optional\` in the header`,
			);
		}
	}
	for (const name of byName.keys()) {
		fail(
			"headers",
			`the header mirrors ${name}, which ${PROTOCOL_NAME} no longer declares`,
		);
	}

	checkRuntimeName(header);
	checkMirroredClasses(header);
}

/**
 * The `objc_runtime_name` attribute is what makes these declarations resolve to
 * the Swift implementations. Swift mangles it from the module and protocol
 * names, so renaming either silently invalidates it.
 */
function checkRuntimeName(header) {
	const moduleName = JSON.parse(read("package.json")).swiftpmConfig?.name;
	if (!moduleName) {
		fail("headers", "package.json no longer declares swiftpmConfig.name");
		return;
	}
	const expected = `_TtP${moduleName.length}${moduleName}${PROTOCOL_NAME.length}${PROTOCOL_NAME}_`;
	const found = header.match(/objc_runtime_name\("([^"]+)"\)/)?.[1];
	if (found !== expected) {
		fail(
			"headers",
			`objc_runtime_name is \`${found}\`, expected \`${expected}\``,
		);
	}
}

/**
 * The mirrored `@interface`s deliberately flatten their superclasses (see the
 * comment in the header), but their availability has to match: ObjC++ that
 * calls an iOS 14 only class outside an availability check does not compile.
 */
function checkMirroredClasses(header) {
	const mirrored = new Map();
	const pattern =
		/(?:API_AVAILABLE\(ios\(([\d.]+)\)\)\s*)?@interface\s+(\w+)\s*:\s*(\w+)\s*</g;
	for (const match of header.matchAll(pattern)) {
		mirrored.set(match[2], { availability: match[1] });
	}

	for (const file of tracked("ios/NewArch").filter((path) =>
		path.endsWith(".swift"),
	)) {
		const source = read(file);
		const declaration = source.match(
			/(?:@available\(iOS\s+([\d.]+)\s*,\s*\*\)\s*)?@objc\((\w+)\)\s*(?:public\s+)?(?:final\s+)?class\s+\w+/,
		);
		if (!declaration) continue;
		const [, availability, objcName] = declaration;
		const found = mirrored.get(objcName);
		if (!found) {
			// Only the classes MenuView.mm instantiates have to be mirrored.
			continue;
		}
		if (found.availability !== availability) {
			fail(
				"headers",
				`${objcName} is \`@available(iOS ${availability ?? "any"})\` in ${file} but the header ` +
					`says \`${found.availability ? `API_AVAILABLE(ios(${found.availability}))` : "unconditional"}\``,
			);
		}
	}
}

checkSources();
checkMirroredHeader();

for (const note of notes) {
	console.log(note);
}
if (failures.length > 0) {
	console.error(`\nSwiftPM package checks failed (${failures.length}):\n`);
	for (const failure of failures) {
		console.error(`  - ${failure}`);
	}
	console.error(
		"\nNo CI job builds the SwiftPM package, so these are the only guards on it.\n" +
			"Fix the mismatch rather than relaxing the check.\n",
	);
	process.exit(1);
}
console.log("SwiftPM package checks passed.");
