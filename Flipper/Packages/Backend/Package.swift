// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Backend",
    platforms: [
        .iOS(.v16),
        .watchOS(.v9),
        .macOS(.v13),
        .tvOS(.v16)
    ],
    products: [
        .library(
            name: "Backend",
            targets: ["Catalog", "Backend", "Infrared"])
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
            name: "Backend",
            path: "Sources/Backend"),
        .target(
            name: "Catalog",
            dependencies: [
                "Backend",
                "Macro",
                .product(name: "Logging", package: "swift-log")
            ],
            path: "Sources/Catalog"),
        .target(
            name: "Infrared",
            dependencies: [
                "Backend",
                .product(name: "Logging", package: "swift-log")
            ],
            path: "Sources/Infrared"),
        .testTarget(
            name: "CatalogTests",
            dependencies: ["Catalog"],
            path: "Tests/Catalog"),
        .testTarget(
            name: "InfraredTests",
            dependencies: ["Infrared"],
            path: "Tests/Infrared"),
        .executableTarget(
            name: "InfraredContractTests",
            dependencies: ["Infrared"],
            path: "Tests/InfraredContract")
    ]
)
