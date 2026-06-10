//
//  ToastContainerConfiguration.swift
//  Overlayer
//
//  Created by Evgeny Blinov on 10.06.2026.
//

import SwiftUI

/// Stack-wide configuration shared by every toast container (top / center / bottom). Set once via `Overlayer.toastContainerConfiguration`.
public struct ToastContainerConfiguration {
    public static let `default` = ToastContainerConfiguration()

    /// Maximum number of toasts visible at the same time across all positions; further toasts are queued.
    public var maxVisibleCount: Int
    /// Vertical gap between stacked toasts.
    public var spacing: CGFloat
    /// Insets of the containers from the safe area. Toasts fill the remaining width.
    public var edgeInsets: EdgeInsets
    /// Animation used for insertion, removal, and re-stacking.
    public var animation: Animation

    public init(
        maxVisibleCount: Int = 3,
        spacing: CGFloat = 8,
        edgeInsets: EdgeInsets = EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16),
        animation: Animation = .spring(response: 0.34, dampingFraction: 0.82)
    ) {
        self.maxVisibleCount = maxVisibleCount
        self.spacing = spacing
        self.edgeInsets = edgeInsets
        self.animation = animation
    }
}
