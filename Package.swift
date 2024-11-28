// swift-tools-version:5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MetaTextKit",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "MetaTextKit",
            targets: [
                "MetaTextKit",
                "MetaTextArea",
                "MetaLabel",
                "MastodonMeta",
                "TwitterMeta",
                "Meta",
            ]
        ),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/DimensionDev/Fuzi.git", from: "3.2.0"),
        .package(url: "https://github.com/SDWebImage/SDWebImage.git", from: "5.20.0"),
        .package(url: "https://github.com/TwidereProject/twitter-text.git", exact: "0.0.4"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "MetaTextArea",
            dependencies: ["Meta", "MetaTextKit"]),
        .target(
            name: "MetaLabel",
            dependencies: ["MetaTextArea"]),
        .target(
            name: "MetaTextKit",
            dependencies: ["Meta"]),
        .target(
            name: "MastodonMeta",
            dependencies: [
                "Meta",
                .product(name: "Fuzi", package: "Fuzi"),
            ]
        ),
        .target(
            name: "TwitterMeta",
            dependencies: [
                "Meta",
                .product(name: "TwitterText", package: "twitter-text"),
            ]
        ),
        .target(
            name: "Meta",
            dependencies: [
                .product(name: "SDWebImage", package: "SDWebImage"),
            ]
        ),
        .testTarget(
            name: "MastodonMetaTests",
            dependencies: ["MastodonMeta"],
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "TwitterMetaTests",
            dependencies: ["TwitterMeta"]
        ),
    ]
)
