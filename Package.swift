// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DJWKeyboardTools",
    
    platforms: [
        .iOS(.v10),
        .macOS(.v10_12),
        .tvOS(.v10)
    ],
    
    
    products: [
        .library(
            name: "DJWKeyboardTools",
            targets: ["DJWKeyboardTools"]),
    ],
    
    dependencies: [
        .package(path: "../DJWBaseVC/"),
        
        ///public
        .package(url: "https://github.com/SnapKit/SnapKit.git", from: "5.0.0")
    ],
    targets: [
       .target(
            name: "DJWKeyboardTools",
            dependencies: [
                "DJWBaseVC",
                
                ///public
                "SnapKit"
       ]),
        .testTarget(
            name: "DJWKeyboardToolsTests",
            dependencies: ["DJWKeyboardTools"]),
    ]
)
