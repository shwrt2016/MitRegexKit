// swift-tools-version:5.7
//
// MitRegexKit Swift Package 描述文件。
//
// 同时支持 iOS / macOS / tvOS / watchOS。
// 使用方式（Xcode）：File → Add Packages... → 输入仓库地址。
// 使用方式（Package.swift 依赖）：
//     .package(url: "https://github.com/your-org/MitRegexKit.git", from: "1.0.0")
//

import PackageDescription

let package = Package(
    name: "MitRegexKit",
    platforms: [
        .iOS(.v12),
        .macOS(.v10_13),
        .tvOS(.v12),
        .watchOS(.v4)
    ],
    products: [
        .library(
            name: "MitRegexKit",
            targets: ["MitRegexKit"]
        )
    ],
    targets: [
        .target(
            name: "MitRegexKit",
            path: "Sources/MitRegexKit"
        ),
        .testTarget(
            name: "MitRegexKitTests",
            dependencies: ["MitRegexKit"],
            path: "Tests/MitRegexKitTests"
        )
    ]
)
