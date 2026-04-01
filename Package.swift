    // swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.
    import PackageDescription

    let package = Package(
        name: "Sentinel",
        platforms: [
            .iOS(.v16),
            .macOS(.v13) // Good practice to include macOS for local tool building
        ],
        products: [
            // Products define the executables and libraries a package produces
            .library(
                name: "Sentinel",
                targets: ["Sentinel"]),
        ],
        targets: [
            // Targets are the basic building blocks of a package.
            .target(
                name: "Sentinel",
                dependencies: [],
                path: "Sources/Sentinel"), // Explicitly point to your Sources folder
            .testTarget(
                name: "SentinelTests",
                dependencies: ["Sentinel"],
                path: "Tests/SentinelTests"),
        ]
    )
