// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "Core",
    platforms: [
        .iOS(.v14),
        .macOS(.v11)
    ],
    products: [
        .library(
            name: "Core",
            targets: ["Core"])
    ],
    targets: [
        .target(
            name: "Core",
            path: "Sources"),
        .testTarget(
            name: "Tests",
            dependencies: ["Core"],
            path: "Tests")
    ]
)
