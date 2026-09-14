// swift-tools-version: 6.4
import PackageDescription

let package = Package(
    name: "JustTonesCore",
    platforms: [.iOS(.v27), .watchOS(.v27)],
    products: [.library(name: "JustTonesCore", targets: ["JustTonesCore"])],
    targets: [
        .target(name: "JustTonesCore"),
        .testTarget(name: "JustTonesCoreTests", dependencies: ["JustTonesCore"]),
    ]
)
