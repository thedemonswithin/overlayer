// swift-tools-version: 6.2
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
    defaultLocalization: "en",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "Overlayer", targets: ["Overlayer"]),
        // Ready-made toast and loading views (Success / Error / Info / Warning, spinner, progress); optional.
        .library(name: "OverlayerDefaults", targets: ["OverlayerDefaults"])
    ],
    targets: [
        .target(name: "Overlayer", resources: [.process("Resources")], swiftSettings: swiftSettings),
        .target(name: "OverlayerDefaults", dependencies: ["Overlayer"], resources: [.process("Resources")], swiftSettings: swiftSettings),
        .testTarget(name: "OverlayerTests", dependencies: ["Overlayer", "OverlayerDefaults"], swiftSettings: swiftSettings)
    ],
    swiftLanguageModes: [.v6]
)
