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
            name: "CoreBluetoothMock",
            url: "https://github.com/NordicSemiconductor/IOS-CoreBluetooth-Mock.git",
            .upToNextMajor(from: "0.13.0"))
    ],
    targets: [
        .target(
            name: "Core",
            dependencies: ["Injector", "CoreBluetoothMock"],
            path: "Sources"),
        .testTarget(
            name: "CoreTests",
            dependencies: ["Core"],
            path: "Tests")
    ]
)
