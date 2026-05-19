// swift-tools-version: 5.9
import PackageDescription

let user = "MeiloonApp"
let repo = "MLControlSDK-iOS"
let tag = "1.0.6"
let baseURL = "https://github.com/\(user)/\(repo)/releases/download/\(tag)"

let package = Package(
    name: "MLControlSDK",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "MLControlSDK",
            targets: [
                "MLControlCore", 
                "JL_BLEKit", 
                "JL_AdvParse", 
                "JL_HashPair", 
                "JL_OTALib", 
                "JLLogHelper"
            ]
        )
    ],
    targets: [
        .binaryTarget(
            name: "MLControlCore",
            url: "\(baseURL)/MLControlCore.xcframework.zip",
            checksum: "409a7a61a0bd19948d9082bab476bc7944db102bae6ced03288ce6aaf2af6223"
        ),
        .binaryTarget(
            name: "JL_BLEKit",
            url: "\(baseURL)/JL_BLEKit.xcframework.zip",
            checksum: "8a756dff21814002a1b0b9a8c1dc8e097606ce6bf99f9d0753f7eb20c5a860ed"
        ),
        .binaryTarget(
            name: "JL_AdvParse",
            url: "\(baseURL)/JL_AdvParse.xcframework.zip",
            checksum: "e60f19e4f1fd59cd9df753299afe02cee1db554e6a0ff0c373a246c8e47ed135"
        ),
        .binaryTarget(
            name: "JL_HashPair",
            url: "\(baseURL)/JL_HashPair.xcframework.zip",
            checksum: "4b65340da4b35eb11f07a3c1186bda47205bdb8a11b0a98d050e5c2343f02686"
        ),
        .binaryTarget(
            name: "JL_OTALib",
            url: "\(baseURL)/JL_OTALib.xcframework.zip",
            checksum: "283f085b8a99399464f3e19c19ec6034fcbc07fa10e67e510c26fc34805e1353"
        ),
        .binaryTarget(
            name: "JLLogHelper",
            url: "\(baseURL)/JLLogHelper.xcframework.zip",
            checksum: "f66b123ecdd0a9e26929bdaf4e95bd9839dbbe71c1b8118c35f2c7abed5baa4b"
        )
    ]
)
