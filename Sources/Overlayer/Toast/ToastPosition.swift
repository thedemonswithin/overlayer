//
//  ToastPosition.swift
//  Overlayer
//
//  Created by Evgeny Blinov on 10.06.2026.
//

import Foundation

/// Where a toast sits on screen. Each position has its own stack, so top, center and bottom toasts can be visible together.
nonisolated public enum ToastPosition: Sendable, Equatable {
    case top
    case bottom
    case center
}
