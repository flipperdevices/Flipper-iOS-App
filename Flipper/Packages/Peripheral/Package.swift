// swift-tools-version:5.6
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
            url: "https://github.com/apple/swift-collections.git",
            from: "1.0.0"),
        .package(
            url: "https://github.com/tonyfreeman/swift-protobuf.git",
            branch: "ignore-invalid-utf8"),
        .package(
            url: "https://github.com/apple/swift-log.git",
            from: "1.4.2")
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
