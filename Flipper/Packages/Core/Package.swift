// swift-tools-version:5.6
import PackageDescription

let package = Package(
    name: "Core",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v15)
    ],
    products: [
        .library(
            name: "Core",
            targets: ["Core"])
    ],
    dependencies: [
        .package(
            name: "Analytics",
            path: "../Analytics"),
        .package(
            name: "Peripheral",
            path: "../Peripheral"),
        .package(
            name: "MFKey32v2",
            path: "../MFKey32v2"),
        .package(
            name: "Catalog",
            path: "../Catalog"),
        .package(
            url: "https://github.com/apple/swift-collections.git",
            from: "1.0.0"),
        .package(
            url: "https://github.com/apple/swift-protobuf.git",
            from: "1.21.0"),
        .package(
            url: "https://github.com/apple/swift-log.git",
            from: "1.4.2"),
        .package(
            url: "https://github.com/swiftstack/radix.git",
            branch: "dev"),
        .package(
            url: "https://github.com/swiftstack/dcompression.git",
            branch: "dev")
    ],
    targets: [
        .target(
            name: "Core",
            dependencies: [
                "Analytics",
                "Peripheral",
                "MFKey32v2",
                "Catalog",
                .product(name: "Base64", package: "radix"),
                .product(name: "DCompression", package: "dcompression"),
                .product(name: "SwiftProtobuf", package: "swift-protobuf"),
                .product(name: "Collections", package: "swift-collections"),
                .product(name: "Logging", package: "swift-log")
            ],
            path: "Sources"),
        .testTarget(
            name: "CoreTests",
            dependencies: ["Core"],
            path: "Tests")
    ]
)
