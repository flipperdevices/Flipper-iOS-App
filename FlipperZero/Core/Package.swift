// swift-tools-version:5.3
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
            name: "Injector",
            path: "../DI"),
        .package(
            name: "SwiftProtobuf",
            url: "https://github.com/apple/swift-protobuf.git",
            from: "1.18.0")
    ],
    targets: [
        .target(
            name: "Core",
            dependencies: ["Injector", "SwiftProtobuf"],
            path: "Sources"),
        .testTarget(
            name: "CoreTests",
            dependencies: ["Core"],
            path: "Tests")
    ]
)
