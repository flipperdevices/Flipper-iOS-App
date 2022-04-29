// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "Peripheral",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v15)
    ],
    products: [
        .library(
            name: "Peripheral",
            targets: ["Peripheral"])
    ],
    dependencies: [
        .package(
            name: "Inject",
            path: "../Inject"),
        .package(
            url: "https://github.com/apple/swift-collections.git",
            .upToNextMajor(from: "1.0.0")),
        .package(
            name: "SwiftProtobuf",
            url: "https://github.com/apple/swift-protobuf.git",
            from: "1.18.0"),
        .package(
            url: "https://github.com/apple/swift-log.git",
            from: "1.4.2")
    ],
    targets: [
        .target(
            name: "Peripheral",
            dependencies: [
                "Inject",
                "SwiftProtobuf",
                .product(name: "Collections", package: "swift-collections"),
                .product(name: "Logging", package: "swift-log")
            ],
            path: "Sources"),
        .testTarget(
            name: "PeripheralTests",
            dependencies: ["Peripheral"],
            path: "Tests")
    ]
)
