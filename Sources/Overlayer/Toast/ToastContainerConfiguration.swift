//
//  ToastContainerConfiguration.swift
//  Overlayer
//
//  Created by Evgeny Blinov on 10.06.2026.
//

public import SwiftUI

/// Stack-wide configuration shared by every toast container (top / center / bottom). Set once via `Overlayer.toastContainerConfiguration`.
nonisolated public struct ToastContainerConfiguration: Sendable {
    public static let `default` = ToastContainerConfiguration()

    /// Maximum number of toasts visible at the same time across all positions; further toasts are queued. Always at least 1: smaller values are raised to 1, since zero would queue every toast forever.
    public var maxVisibleCount: Int {
        didSet { maxVisibleCount = max(1, maxVisibleCount) }
    }
    /// Vertical gap between stacked toasts.
    public var spacing: CGFloat
    /// Insets of the containers from the safe area.
    public var edgeInsets: EdgeInsets
    /// Widest a toast gets; on wider screens (iPad, landscape) toasts are centred at this width. `nil` lets toasts fill the width between `edgeInsets`.
    public var maxWidth: CGFloat?
    /// Animation used for insertion, removal, and re-stacking.
    public var animation: Animation

    public init(
        maxVisibleCount: Int = 3,
        spacing: CGFloat = 8,
        edgeInsets: EdgeInsets = EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16),
        maxWidth: CGFloat? = 500,
        animation: Animation = .spring(response: 0.34, dampingFraction: 0.82)
    ) {
        self.maxVisibleCount = max(1, maxVisibleCount)
        self.spacing = spacing
        self.edgeInsets = edgeInsets
        self.maxWidth = maxWidth
        self.animation = animation
    }
}
