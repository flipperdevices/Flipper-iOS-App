// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "Bluetooth",
    platforms: [
        .iOS(.v14),
        .macOS(.v11)
    ],
    products: [
        .library(
            name: "Bluetooth",
            targets: ["Bluetooth"])
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
            name: "Bluetooth",
            dependencies: [
                "Inject",
                "SwiftProtobuf",
                .product(name: "Collections", package: "swift-collections"),
                .product(name: "Logging", package: "swift-log")
            ],
            path: "Sources"),
        .testTarget(
            name: "BluetoothTests",
            dependencies: ["Bluetooth"],
            path: "Tests")
    ]
)
