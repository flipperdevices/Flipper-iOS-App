// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Core",
    platforms: [
        .iOS(.v16),
        .watchOS(.v9),
        .macOS(.v13),
        .tvOS(.v16)
    ],
    products: [
        .library(
            name: "Core",
            targets: ["Core"])
    ],
    dependencies: [
        .package(
            name: "Macro",
            path: "../Macro"),
        .package(
            name: "Analytics",
            path: "../Analytics"),
        .package(
            name: "Activity",
            path: "../Activity"),
        .package(
            name: "Peripheral",
            path: "../Peripheral"),
        .package(
            name: "MFKey32v2",
            path: "../MFKey32v2"),
        .package(
            name: "Backend",
            path: "../Backend"),
        .package(
            url: "https://github.com/apple/swift-collections.git",
            from: "1.1.0"),
        .package(
            url: "https://github.com/apple/swift-protobuf.git",
            from: "1.26.0"),
        .package(
            url: "https://github.com/apple/swift-log.git",
            from: "1.5.4"),
        // Pinned to exact revisions (was branch: "dev") because upstream
        // force-pushed dev, removing the previously resolved commits and
        // breaking clean checkouts (e.g. Xcode Cloud). These revisions have
        // byte-identical trees to the last known-good pins. Stream is a
        // transitive dep of dcompression (branch: "dev") and can't be
        // revision-overridden here, so it stays locked via Package.resolved.
        .package(
            url: "https://github.com/swiftstack/radix.git",
            revision: "dd87b82361f7ee9db806d94c8e6043229c5c9c7d"),
        .package(
            url: "https://github.com/swiftstack/dcompression.git",
            revision: "abc4483b7999c6a63a8053a12e72c6a7f953e763")
    ],
    targets: [
        .target(
            name: "Core",
            dependencies: [
                "Macro",
                "Analytics",
                "Activity",
                "Peripheral",
                "MFKey32v2",
                .product(name: "Backend", package: "Backend"),
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
