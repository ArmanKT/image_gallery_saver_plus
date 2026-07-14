// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "image_gallery_saver_plus",
    platforms: [
        .iOS("12.0")
    ],
    products: [
        .library(name: "image-gallery-saver-plus", targets: ["image_gallery_saver_plus"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "image_gallery_saver_plus",
            dependencies: [],
            resources: [
                // If your plugin requires a privacy manifest, for example if it uses any required
                // reason APIs, update the PrivacyInfo.xcprivacy file to describe your plugin's
                // privacy impact, and then uncomment these lines. For more information, see
                // https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
                // .process("PrivacyInfo.xcprivacy"),
            ]
        )
    ]
)

