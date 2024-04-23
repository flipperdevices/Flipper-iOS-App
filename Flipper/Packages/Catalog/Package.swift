// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Catalog",
    platforms: [
        .iOS(.v16),
        .watchOS(.v9),
        .macOS(.v13),
        .tvOS(.v16)
    ],
    products: [
        .library(
            name: "Catalog",
            targets: ["Catalog"])
    ],
    dependencies: [
        .package(
            name: "Macro",
            path: "../Macro"),
        .package(
            url: "https://github.com/apple/swift-log.git",
            from: "1.5.4")
    ],
    targets: [
        .target(
            name: "Catalog",
            dependencies: [
                "Macro",
                .product(name: "Logging", package: "swift-log")
            ],
            path: "Sources"),
        .testTarget(
            name: "CatalogTests",
            dependencies: ["Catalog"],
            path: "Tests")
    ]
)
