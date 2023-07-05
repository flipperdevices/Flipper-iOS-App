// swift-tools-version:5.6
import PackageDescription

let package = Package(
    name: "Catalog",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v15)
    ],
    products: [
        .library(
            name: "Catalog",
            targets: ["Catalog"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-log.git",
            from: "1.4.2")
    ],
    targets: [
        .target(
            name: "Catalog",
            dependencies: [
                .product(name: "Logging", package: "swift-log")
            ],
            path: "Sources"),
        .testTarget(
            name: "CatalogTests",
            dependencies: ["Catalog"],
            path: "Tests")
    ]
)
