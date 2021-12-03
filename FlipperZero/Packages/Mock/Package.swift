// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "Mock",
    platforms: [
        .iOS(.v14),
        .macOS(.v11)
    ],
    products: [
        .library(
            name: "Mock",
            targets: ["Mock"])
    ],
    dependencies: [
        .package(
            name: "Core",
            path: "../Core"),
        .package(
            name: "Inject",
            path: "../Inject"),
        .package(
            url: "https://github.com/apple/swift-collections.git",
            .upToNextMajor(from: "1.0.0")),
        .package(
            name: "SwiftProtobuf",
            url: "https://github.com/apple/swift-protobuf.git",
            from: "1.18.0")
    ],
    targets: [
        .target(
            name: "Mock",
            dependencies: [
                "Core",
                "Inject",
                "SwiftProtobuf",
                .product(name: "Collections", package: "swift-collections")
            ],
            path: "Sources"),
        .testTarget(
            name: "MockTests",
            dependencies: ["Mock"],
            path: "Tests")
    ]
)
