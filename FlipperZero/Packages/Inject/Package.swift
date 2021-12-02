// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "Inject",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
        .tvOS(.v14)
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
