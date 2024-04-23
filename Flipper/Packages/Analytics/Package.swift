// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Analytics",
    platforms: [
        .iOS(.v16),
        .watchOS(.v9),
        .macOS(.v13),
        .tvOS(.v16)
    ],
    products: [
        .library(
            name: "Analytics",
            targets: ["Analytics"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-log.git",
            from: "1.5.4"),
        .package(
            url: "https://github.com/Countly/countly-sdk-ios.git",
            from: "24.4.0"),
        .package(
            url: "https://github.com/apple/swift-protobuf.git",
            from: "1.26.0")
    ],
    targets: [
        .target(
            name: "Analytics",
            dependencies: [
                .product(name: "SwiftProtobuf", package: "swift-protobuf"),
                .product(name: "Countly", package: "countly-sdk-ios"),
                .product(name: "Logging", package: "swift-log")
            ],
            path: "Sources"),
        .testTarget(
            name: "AnalyticsTests",
            dependencies: ["Analytics"],
            path: "Tests")
    ]
)
