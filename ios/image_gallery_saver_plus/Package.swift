// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "image_gallery_saver_plus",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        .library(
            name: "image-gallery-saver-plus",
            targets: ["image_gallery_saver_plus"]
        )
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "image_gallery_saver_plus",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ],
            resources: [
                .process("PrivacyInfo.xcprivacy")
            ]
        )
    ]
)

