// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Notifications",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v15)
    ],
    products: [
        .library(
            name: "Notifications",
            targets: ["Notifications"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-log.git",
            from: "1.4.2"),
        .package(
            url: "https://github.com/tonyfreeman/firebase-ios-sdk",
            branch: "master")
    ],
    targets: [
        .target(
            name: "Notifications",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
                .product(name: "FirebaseMessaging", package: "firebase-ios-sdk")
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "NotificationsTests",
            dependencies: ["Notifications"],
            path: "Tests")
    ]
)
