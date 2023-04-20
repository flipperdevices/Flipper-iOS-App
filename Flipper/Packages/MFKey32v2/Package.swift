// swift-tools-version:5.6
import PackageDescription

let package = Package(
    name: "MFKey32v2",
    products: [
        .library(
            name: "MFKey32v2",
            targets: ["MFKey32v2"])
    ],
    targets: [
        .target(
            name: "CCrapto1"),
        .target(
            name: "MFKey32v2",
            dependencies: ["CCrapto1"]),
        .testTarget(
            name: "MFKey32v2Tests",
            dependencies: ["MFKey32v2"])
    ]
)
