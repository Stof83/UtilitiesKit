// swift-tools-version: 5.9

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "UtilitiesKit",
    platforms: [
        .iOS(.v15), .macOS(.v11)
    ],
    products: [
        .library(name: "UtilitiesKit", targets: ["UtilitiesKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/malcommac/SwiftDate.git", .upToNextMajor(from: "7.0.0")),
        .package(url: "https://github.com/onevcat/Kingfisher.git", .upToNextMajor(from: "7.0.0")),
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "601.0.1"),
    ],
    targets: [
        .macro(
            name: "MacrosImplementation",
            dependencies: [
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftDiagnostics", package: "swift-syntax"),
            ],
            path: "Sources/Macros/Implementation"
        ),
        .target(
            name: "MacrosInterface",
            dependencies: ["MacrosImplementation"],
            path: "Sources/Macros/Interface"
        ),
        .target(
            name: "UtilitiesKit",
            dependencies: [
                .product(name: "SwiftDate", package: "SwiftDate"),
                .product(name: "Kingfisher", package: "Kingfisher"),
                .product(name: "SwiftParser", package: "swift-syntax"),
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                "MacrosInterface"
            ],
            path: "Sources/UtilitiesKit"
        ),
        .executableTarget(
            name: "MacrosPlayground",
            dependencies: ["MacrosInterface"],
            path: "Sources/Macros/Playground"
        ),
    ]
)
