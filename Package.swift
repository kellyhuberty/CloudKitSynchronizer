// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CloudKitSynchronizer",
    platforms: [
        .iOS("16.0"),
        .macOS("13.0"),
        .tvOS("16.0"),
        .watchOS("9.0"),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "CloudKitSynchronizer",
            targets: ["CloudKitSynchronizer"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(name:"GRDB", url: "https://github.com/groue/GRDB.swift.git", from: "6.12.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "CloudKitSynchronizer",
            dependencies: [
                "GRDB"
            ]
        )
// TODO: Need to figure out a good way to build a test target with the limitations of
// a package.swift. (Provisioning, CloudKit integration)
//        .testTarget(
//            name: "CloudKitSynchronizerTests",
//            dependencies: ["CloudKitSynchronizer"],
//            path: "IntegrationTests")
    ]
)

