// swift-tools-version: 6.4
import PackageDescription

// Swift 6 language mode with approachable concurrency: everything is main-actor isolated unless marked `nonisolated`, which fits a UI-only library.
let swiftSettings: [SwiftSetting] = [
    .defaultIsolation(MainActor.self),
    .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
    .enableUpcomingFeature("InferIsolatedConformances"),
    .enableUpcomingFeature("ExistentialAny"),
    .enableUpcomingFeature("MemberImportVisibility"),
    .enableUpcomingFeature("InternalImportsByDefault"),
    .enableUpcomingFeature("ImmutableWeakCaptures")
]

let package = Package(
    name: "Overlayer",
    platforms: [.iOS(.v16)],
    products: [.library(name: "Overlayer", targets: ["Overlayer"])],
    targets: [
        .target(name: "Overlayer", swiftSettings: swiftSettings),
        .testTarget(name: "OverlayerTests", dependencies: ["Overlayer"], swiftSettings: swiftSettings)
    ],
    swiftLanguageModes: [.v6]
)
