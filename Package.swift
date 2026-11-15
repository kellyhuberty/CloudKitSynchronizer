// swift-tools-version:6.2
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
        .package(url: "https://github.com/groue/GRDB.swift.git", from: "7.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "CloudKitSynchronizer",
            dependencies: [
//                "GRDB"
//                .library(name: "GRDB", package: "GRDB.swift")
                .product(name: "GRDB", package: "GRDB.swift")
            ]
        ),
        // CloudKit-free logic tests. CloudKit integration tests need signing and an
        // iCloud account, so they live in the TestApp's CloudKitSynchronizerIntegrationTests target.
        .testTarget(
            name: "CloudKitSynchronizerTests",
            dependencies: ["CloudKitSynchronizer"]
        )
    ],
    swiftLanguageModes: [.v6]
)
