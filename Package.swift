// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "TeslaSwift",
    platforms: [
        .macOS(.v10_12), .iOS(.v15), .watchOS(.v3), .tvOS(.v10)
    ],
    products: [
        .library(name: "TeslaSwift", targets: ["TeslaSwift"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(name: "TeslaSwift"),
    ]
)
