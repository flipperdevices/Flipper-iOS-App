// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Peripheral",
    platforms: [
        .iOS(.v16),
        .watchOS(.v9),
        .macOS(.v13),
        .tvOS(.v16)
    ],
    products: [
        .library(
            name: "Peripheral",
            targets: ["Peripheral"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-collections.git",
            from: "1.1.0"),
        .package(
            url: "https://github.com/apple/swift-protobuf.git",
            from: "1.26.0"),
        .package(
            url: "https://github.com/apple/swift-log.git",
            from: "1.5.4")
    ],
    targets: [
        .target(
            name: "Peripheral",
            dependencies: [
                .product(name: "SwiftProtobuf", package: "swift-protobuf"),
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
