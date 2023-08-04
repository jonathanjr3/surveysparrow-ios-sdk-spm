// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "surveysparrow-ios-sdk-spm",
    platforms: [
        .iOS(.v11), .macOS(.v10_13)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "surveysparrow-ios-sdk-spm",
            targets: ["surveysparrow-ios-sdk-spm"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "surveysparrow-ios-sdk-spm",
            path: "SurveySparrow/SurveySparrowSdk"),
        .testTarget(
            name: "surveysparrow-ios-sdk-spmTests",
            dependencies: ["surveysparrow-ios-sdk-spm"],
            path: "SurveySparrow/SurveySparrowSdkTests"),
    ]
)
