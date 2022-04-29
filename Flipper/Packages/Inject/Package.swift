// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "Inject",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v15)
    ],
    products: [
        .library(
            name: "Inject",
            targets: ["Inject"])
    ],
    targets: [
        .target(
            name: "Inject",
            path: "Sources"),
        .testTarget(
            name: "InjectTests",
            dependencies: ["Inject"],
            path: "Tests")
    ]
)
