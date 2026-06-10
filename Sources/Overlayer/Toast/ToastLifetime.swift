//
//  ToastLifetime.swift
//  Overlayer
//
//  Created by Evgeny Blinov on 10.06.2026.
//

import Foundation

public enum ToastLifetime: Sendable, Equatable {
    /// Auto-dismiss after the given number of seconds.
    case seconds(TimeInterval)
    /// Never auto-dismiss; the toast lives until dismissed manually (close button, swipe, or `dismiss`).
    case sticky
    
    public static let `default` = ToastLifetime.seconds(4)

    /// Total visible duration, or `nil` when the toast is sticky.
    var duration: TimeInterval? {
        switch self {
        case .seconds(let value): return value
        case .sticky: return nil
        }
    }
}
