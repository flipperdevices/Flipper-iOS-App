// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "Analytics",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v15)
    ],
    products: [
        .library(
            name: "Analytics",
            targets: ["Analytics"])
    ],
    dependencies: [
        .package(
            name: "Inject",
            path: "../Inject"),
        .package(
            name: "Logging",
            url: "https://github.com/apple/swift-log.git",
            from: "1.4.2"),
        .package(
            name: "Countly",
            url: "https://github.com/Countly/countly-sdk-ios.git",
            from: "21.11.2")
    ],
    targets: [
        .target(
            name: "Analytics",
            dependencies: [
                "Inject",
                "Logging",
                "Countly"
            ],
            path: "Sources"),
        .testTarget(
            name: "AnalyticsTests",
            dependencies: ["Analytics"],
            path: "Tests")
    ]
)
