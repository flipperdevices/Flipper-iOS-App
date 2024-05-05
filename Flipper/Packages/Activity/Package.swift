// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Activity",
    platforms: [
        .iOS(.v16),
        .watchOS(.v9),
        .macOS(.v13),
        .tvOS(.v16)
    ],
    products: [
        .library(
            name: "Activity",
            targets: ["Activity"])
    ],
    targets: [
        .target(
            name: "Activity",
            path: "Sources"),
        .testTarget(
            name: "ActivityTests",
            dependencies: ["Activity"],
            path: "Tests")
    ]
)
