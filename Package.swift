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
let usedRootEntries: Set<String> = ["ios", "spm-support", "Package.swift"]
let unusedRootEntries = try! FileManager.default.contentsOfDirectory(atPath: Context.packageDirectory)
    .filter { !usedRootEntries.contains($0) }
    .sorted()

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
            exclude: unusedRootEntries + [
                "ios/RCTMenu.xcodeproj", "ios/Menu-Bridging-Header.h",
                "ios/MenuViewManager.mm", "ios/NewArch/MenuView.h", "ios/NewArch/MenuView.mm",
            ],
            sources: ["ios/Shared", "ios/OldArch", "ios/NewArch", "spm-support/Imports.swift"]
        ),
        .target(
            name: "ReactNativeMenuObjC",
            dependencies: [.target(name: "react_native_menu")] + reactHeaders,
            path: "ios",
            exclude: [
                "RCTMenu.xcodeproj", "Menu-Bridging-Header.h", "Shared", "OldArch",
                "NewArch/FabricActionSheetView.swift", "NewArch/FabricMenuViewImplementation.swift",
                "NewArch/FabricViewImplementationProtocol.swift",
            ],
            sources: ["MenuViewManager.mm", "NewArch/MenuView.mm"],
            publicHeadersPath: "NewArch",
            cSettings: [
                .define("RCT_NEW_ARCH_ENABLED", to: "1"),
                .headerSearchPath("../spm-headers"),
            ],
            cxxSettings: [
                .define("RCT_NEW_ARCH_ENABLED", to: "1"),
                .define("DEBUG", .when(configuration: .debug)),
                .define("NDEBUG", .when(configuration: .release)),
                .headerSearchPath("../spm-headers"),
            ]
        ),
    ],
    swiftLanguageModes: [.v5],
    cxxLanguageStandard: .cxx20
)
