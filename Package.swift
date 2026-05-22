// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Traffy",
    platforms: [
        .macOS(.v13)
    ],
    targets: [
        .executableTarget(
            name: "Traffy"
        )
    ]
)
