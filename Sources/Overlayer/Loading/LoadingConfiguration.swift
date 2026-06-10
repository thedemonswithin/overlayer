//
//  LoadingConfiguration.swift
//  Overlayer
//
//  Created by Evgeny Blinov on 10.06.2026.
//

import SwiftUI

/// Parametric knobs for a loading overlay. By default it blocks interaction with the views beneath it; set `isBlocking = false` to let touches pass through (a purely visual overlay).
public struct LoadingConfiguration {
    public static let `default` = LoadingConfiguration()

    /// Whether the overlay blocks interaction with the views beneath it. `true` (default) captures every touch; `false` lets touches pass straight through to the app — the overlay becomes visual-only, so don't put interactive controls on a non-blocking loader.
    public var isBlocking: Bool
    /// Backdrop drawn behind the loading view. Use a dim colour, a material, or `Color.clear` (typical for a non-blocking overlay).
    public var backgroundStyle: AnyShapeStyle
    /// Whether the backdrop extends under the safe area (status bar, home indicator) for a full-screen cover.
    public var ignoresSafeArea: Bool
    /// Animation used when the overlay appears and disappears.
    public var animation: Animation

    public init(
        isBlocking: Bool = true,
        backgroundStyle: AnyShapeStyle = AnyShapeStyle(Color.black.opacity(0.25)),
        ignoresSafeArea: Bool = true,
        animation: Animation = .easeInOut(duration: 0.2)
    ) {
        self.isBlocking = isBlocking
        self.backgroundStyle = backgroundStyle
        self.ignoresSafeArea = ignoresSafeArea
        self.animation = animation
    }
}
