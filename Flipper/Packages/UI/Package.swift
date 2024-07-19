// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "UI",
    platforms: [
        .iOS(.v16),
        .watchOS(.v9),
        .macOS(.v13),
        .tvOS(.v16)
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
            name: "Notifications",
            path: "../Notifications"),
        .package(
            name: "Backend",
            path: "../Backend"), // Remove when create infrared model in Core
        .package(
            url: "https://github.com/gonzalezreal/swift-markdown-ui",
            from: "2.3.1")
    ],
    targets: [
        .target(
            name: "UI",
            dependencies: [
                "Core",
                "Analytics",
                "Notifications",
                .product(name: "Backend", package: "Backend"),
                .product(name: "MarkdownUI", package: "swift-markdown-ui")
            ],
            path: "Sources"),
        .testTarget(
            name: "UITests",
            dependencies: ["UI"],
            path: "Tests")
    ]
)
