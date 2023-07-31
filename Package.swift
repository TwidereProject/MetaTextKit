// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MetaTextKit",
    platforms: [.iOS(.v14)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "MetaTextKit",
            targets: ["MetaTextKit", "MastodonMeta", "TwitterMeta"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.7.0"),
        .package(url: "https://github.com/SDWebImage/SDWebImage.git", from: "5.17.0"),
        .package(url: "https://github.com/TwidereProject/Fuzi.git", .branch("feature/raw-dump")),
        .package(url: "https://github.com/scinfu/SwiftSoup.git", from: "2.6.1"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "MetaTextKit",
            dependencies: ["Meta"]),
        .target(
            name: "MastodonMeta",
            dependencies: [
                "Meta",
                "Fuzi",
                "Alamofire",
                .product(name: "SDWebImage", package: "SDWebImage"),
            ]),
        .target(
            name: "TwitterMeta",
            dependencies: ["Meta"]),
        .target(
            name: "Meta"),
        .testTarget(
            name: "MastodonMetaTests",
            dependencies: ["MastodonMeta", "SwiftSoup", "Fuzi"],
            resources: [
                .process("Resources")
            ]),
    ]
)
