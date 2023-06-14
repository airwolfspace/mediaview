// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "ASMediaView",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "ASMediaView",
            targets: ["ASMediaView"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "ASMediaView",
            dependencies: []),
        .testTarget(
            name: "ASMediaViewTests",
            dependencies: ["ASMediaView"]),
    ]
)
