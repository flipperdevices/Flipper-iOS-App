// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "UI",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
        .tvOS(.v14)
    ],
    products: [
        .library(
            name: "UI",
            targets: ["UI"])
    ],
    dependencies: [
        .package(name: "Core", path: "../Core"),
        .package(name: "Mock", path: "../Mock")
    ],
    targets: [
        .target(
            name: "UI",
            dependencies: ["Core", "Mock"],
            path: "Sources"),
        .testTarget(
            name: "UITests",
            dependencies: ["UI"],
            path: "Tests")
    ]
)
