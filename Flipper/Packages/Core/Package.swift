// swift-tools-version:5.5
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
    dependencies: [
        .package(
            name: "Inject",
            path: "../Inject"),
        .package(
            name: "Peripheral",
            path: "../Peripheral"),
        .package(
            name: "Collections",
            url: "https://github.com/apple/swift-collections.git",
            .upToNextMajor(from: "1.0.0")),
        .package(
            name: "SwiftProtobuf",
            url: "https://github.com/apple/swift-protobuf.git",
            from: "1.18.0"),
        .package(
            name: "Logging",
            url: "https://github.com/apple/swift-log.git",
            from: "1.4.2"),
        .package(
            name: "DCompression",
            url: "https://github.com/swiftstack/dcompression.git",
            branch: "dev")
    ],
    targets: [
        .target(
            name: "Core",
            dependencies: [
                "Inject",
                "Peripheral",
                "SwiftProtobuf",
                "DCompression",
                "Collections",
                "Logging"
            ],
            path: "Sources"),
        .testTarget(
            name: "CoreTests",
            dependencies: ["Core"],
            path: "Tests")
    ]
)
