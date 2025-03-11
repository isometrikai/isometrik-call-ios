// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ISMSwiftCall",
    platforms:[.iOS(.v15),
    ], products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "ISMSwiftCall",
            targets: ["ISMSwiftCall"]),
    ],
    dependencies: [
        .package(url: "https://github.com/livekit/client-sdk-swift", from: "2.3.0"),
        .package(url: "https://github.com/emqx/CocoaMQTT.git", from: "2.1.6"),
        .package(url: "https://github.com/daltoniam/Starscream", exact: "4.0.4")
    ],
    targets: [
        .target(
            name: "ISMSwiftCall",
            dependencies: [
                            .product(name: "LiveKit", package: "client-sdk-swift"),
                            .product(name: "CocoaMQTT", package: "cocoamqtt"),
                            .product(name: "CocoaMQTTWebSocket", package: "cocoamqtt"),
                            .product(name: "Starscream", package: "starscream"),
            resources: [.process("Sounds")]
            ),
    ],
    swiftLanguageVersions: [
        .v5,
    ]
)
