// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "Injector",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
        .tvOS(.v14)
    ],
    products: [
        .library(
            name: "Injector",
            targets: ["Injector"])
    ],
    targets: [
        .target(
            name: "Injector",
            path: "Sources"),
        .testTarget(
            name: "InjectorTests",
            dependencies: ["Injector"],
            path: "Tests")
    ]
)
