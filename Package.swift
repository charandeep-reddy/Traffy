// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Traffy",
    platforms: [
        .macOS(.v26)
    ],
    targets: [
        .executableTarget(
            name: "Traffy"
        )
    ]
)
