// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "INDIKit",
    platforms: [
        .iOS(.v26),
        .macOS(.v26)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "INDIProtocol",
            targets: ["INDIProtocol"]
        ),
        .library(
            name: "INDIState",
            targets: ["INDIState"]
        ),
        .library(
            name: "INDIStateUI",
            targets: ["INDIStateUI"]
        ),
        .library(
            name: "INDIKit",
            targets: ["INDIKit"]
        ),
        .executable(
            name: "indikit-cli",
            targets: ["INDIKitCLI"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "INDIProtocol"
        ),
        .target(
            name: "INDIState",
            dependencies: ["INDIProtocol"]
        ),
        .target(
            name: "INDIStateUI",
            dependencies: ["INDIState", "INDIProtocol"]
        ),
        .target(
            name: "INDIKit",
            dependencies: ["INDIProtocol", "INDIState", "INDIStateUI"]
        ),
        .executableTarget(
            name: "INDIKitCLI",
            dependencies: ["INDIProtocol", "INDIState"]
        ),
        .testTarget(
            name: "INDIKitTests",
            dependencies: ["INDIProtocol", "INDIState"]
        )
    ],
    swiftLanguageModes: [
        .v6
    ]
)
