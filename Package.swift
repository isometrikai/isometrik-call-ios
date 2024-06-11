// swift-tools-version: 5.10
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
        .package(url: "https://github.com/livekit/client-sdk-swift", from: "2.0.6"),
        .package(url: "https://github.com/emqx/CocoaMQTT.git", from: "2.1.6"),
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "7.11.0"),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON", from: "5.0.2")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "ISMSwiftCall",
            dependencies: [ .product(name: "Kingfisher", package: "kingfisher"),
                .product(name: "LiveKit", package: "client-sdk-swift"),
                            .product(name: "CocoaMQTT", package: "cocoamqtt"),
                            .product(name: "SwiftyJSON", package: "swiftyjson"),
            ]
            )
    ]
)
