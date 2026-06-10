//
//  ToastHapticFeedback.swift
//  Overlayer
//
//  Created by Evgeny Blinov on 10.06.2026.
//

import UIKit

/// Haptic played when a toast becomes visible. Fully parametric so each configuration can opt into the feedback that fits its semantics.
public enum ToastHapticFeedback: Sendable {
    case none
    case selection
    case impact(UIImpactFeedbackGenerator.FeedbackStyle)
    case notification(UINotificationFeedbackGenerator.FeedbackType)
    
    @MainActor func trigger() {
        switch self {
        case .none: break
        case .selection: UISelectionFeedbackGenerator().selectionChanged()
        case .impact(let style): UIImpactFeedbackGenerator(style: style).impactOccurred()
        case .notification(let type): UINotificationFeedbackGenerator().notificationOccurred(type)
        }
    }
}
