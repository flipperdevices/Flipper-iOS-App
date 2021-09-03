// swift-tools-version:5.3
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
    ],
    targets: [
        .target(
            name: "UI",
            dependencies: ["Core"],
            path: "Sources"),
        .testTarget(
            name: "UITests",
            dependencies: ["UI"],
            path: "Tests")
    ]
)
