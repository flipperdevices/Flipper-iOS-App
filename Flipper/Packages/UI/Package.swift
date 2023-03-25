// swift-tools-version:5.6
import PackageDescription

let package = Package(
    name: "UI",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v15)
    ],
    products: [
        .library(
            name: "UI",
            targets: ["UI"])
    ],
    dependencies: [
        .package(
            name: "Core",
            path: "../Core"),
        .package(
            name: "Analytics",
            path: "../Analytics"),
        .package(
            url: "https://github.com/airbnb/lottie-ios.git",
            from: "3.3.0"),
        .package(
            url: "https://github.com/tonyfreeman/MarkdownUI.git",
            branch: "main")
    ],
    targets: [
        .target(
            name: "UI",
            dependencies: [
                "Core",
                "Analytics",
                .product(name: "Lottie", package: "lottie-ios"),
                .product(name: "MarkdownUI", package: "MarkdownUI")
            ],
            path: "Sources"),
        .testTarget(
            name: "UITests",
            dependencies: ["UI"],
            path: "Tests")
    ]
)
