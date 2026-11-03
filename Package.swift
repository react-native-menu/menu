// swift-tools-version: 6.0

import Foundation
import PackageDescription

// React Native evaluates this package through build/generated/autolinking/libs/.
let reactHeaders: [Target.Dependency] = [
    .product(name: "ReactHeaders", package: "ReactNative"),
    .product(name: "ReactNativeHeaders", package: "ReactNative"),
    .product(name: "ReactNativeDependenciesHeaders", package: "ReactNative"),
    .product(name: "ReactAppHeaders", package: "React-GeneratedCode"),
]

// The Swift import shim lives outside ios/. Keep unrelated repository and npm
// package contents out of SwiftPM's resource discovery.
let usedRootEntries: Set<String> = ["ios", "spm-support", "spm-headers", "Package.swift"]
let unusedRootEntries = try! FileManager.default.contentsOfDirectory(atPath: Context.packageDirectory)
    .filter { !usedRootEntries.contains($0) }
    .sorted()

// Discover sources as folders, splitting the podspec's native and Swift files.
// Exclude projects and non-source files from both targets.
let iosDirectory = URL(fileURLWithPath: Context.packageDirectory).appendingPathComponent("ios")
let iosEntries = try! FileManager.default.subpathsOfDirectory(atPath: iosDirectory.path)
    .filter { !$0.contains(".xcodeproj/") }
func unusedIosEntries(sourceExtensions: Set<String>) -> [String] {
    iosEntries.filter { entry in
        let url = iosDirectory.appendingPathComponent(entry)
        if url.pathExtension == "xcodeproj" { return true }
        let isFile = try! url.resourceValues(forKeys: [.isRegularFileKey]).isRegularFile == true
        return isFile && (!sourceExtensions.contains(url.pathExtension)
            || entry == "Menu-Bridging-Header.h")
    }
    .map { "ios/" + $0 }
    .sorted()
}
let unusedSwiftIosEntries = unusedIosEntries(sourceExtensions: ["swift"])
let unusedObjCIosEntries = unusedIosEntries(sourceExtensions: ["h", "m", "mm"])

let package = Package(
    name: "react_native_menu",
    platforms: [.iOS("15.1")],
    products: [
        .library(name: "react_native_menu", targets: ["react_native_menu", "ReactNativeMenuObjC"]),
    ],
    dependencies: [
        .package(name: "ReactNative", path: "../../../../xcframeworks"),
        .package(name: "React-GeneratedCode", path: "../../../ios"),
    ],
    targets: [
        // Preserve the CocoaPods Swift module name. Swift depends on React only;
        // the Fabric adapter below depends on Swift, avoiding a target cycle.
        .target(
            name: "react_native_menu",
            dependencies: reactHeaders,
            path: ".",
            exclude: unusedRootEntries + ["spm-headers"] + unusedSwiftIosEntries,
            sources: ["ios/Shared", "ios/OldArch", "ios/NewArch", "spm-support"]
        ),
        .target(
            name: "ReactNativeMenuObjC",
            dependencies: [.target(name: "react_native_menu")] + reactHeaders,
            // Root the target here so its empty public module stays outside ios/.
            path: ".",
            exclude: unusedRootEntries + ["spm-support"] + unusedObjCIosEntries,
            sources: ["ios"],
            // Required: without it SwiftPM looks for a default include/ folder, which this target does not have.
            publicHeadersPath: "spm-headers/public",
            cSettings: [
                .define("RCT_NEW_ARCH_ENABLED", to: "1"),
                .headerSearchPath("ios/NewArch"),
                .headerSearchPath("spm-headers"),
            ],
            cxxSettings: [
                .define("RCT_NEW_ARCH_ENABLED", to: "1"),
                .define("DEBUG", .when(configuration: .debug)),
                .define("NDEBUG", .when(configuration: .release)),
                .headerSearchPath("ios/NewArch"),
                .headerSearchPath("spm-headers"),
            ]
        ),
    ],
    swiftLanguageModes: [.v5],
    cxxLanguageStandard: .cxx20
)
