// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Overlayer",
    platforms: [.iOS(.v16)],
    products: [.library(name: "Overlayer", targets: ["Overlayer"])],
    targets: [
        .target(name: "Overlayer"),
        .testTarget(name: "OverlayerTests", dependencies: ["Overlayer"])
    ]
)
