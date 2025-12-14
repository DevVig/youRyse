// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "YouRyse",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "YouRyse", targets: ["YouRyse"])
    ],
    dependencies: [
        // Dependencies go here.
    ],
    targets: [
        .executableTarget(
            name: "YouRyse",
            dependencies: [],
            path: "Sources"
        )
    ]
)
