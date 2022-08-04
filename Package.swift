// swift-tools-version:5.5
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
        .package(url: "https://github.com/cezheng/Fuzi.git", from: "3.1.0"),
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.5.0"),
        .package(url: "https://github.com/SDWebImage/SDWebImage.git", from: "5.12.0"),
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
                .product(name: "Alamofire", package: "Alamofire"),
                .product(name: "SDWebImage", package: "SDWebImage"),
            ]
        ),
        .target(
            name: "TwitterMeta",
            dependencies: ["Meta"]
        ),
        .target(
            name: "Meta"
        ),
        .testTarget(
            name: "MastodonMetaTests",
            dependencies: ["MastodonMeta"],
            resources: [
                .process("Resources")
            ]
        ),
    ]
)
