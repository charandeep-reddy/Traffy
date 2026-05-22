// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "TrafficIndicator",
    platforms: [
        .macOS(.v13)
    ],
    targets: [
        .executableTarget(
            name: "TrafficIndicator"
        )
    ]
)
