//
//  ToastLifetime.swift
//  Overlayer
//
//  Created by Evgeny Blinov on 10.06.2026.
//

public import Foundation

/// How long a toast stays on screen before it hides itself.
nonisolated public enum ToastLifetime: Sendable, Equatable {
    /// Auto-dismiss after the given number of seconds.
    ///
    /// A value that is not finite or longer than `maximumSeconds` behaves like `.sticky`; zero or a negative value hides the toast immediately.
    case seconds(TimeInterval)
    /// Never auto-dismiss; the toast lives until dismissed manually (close button, swipe, or `dismiss`).
    case sticky

    public static let `default` = ToastLifetime.seconds(4)

    /// Longest lifetime treated as a countdown (one year); anything longer is effectively sticky.
    public static let maximumSeconds: TimeInterval = 365 * 24 * 60 * 60

    /// Total visible duration, or `nil` when the toast never hides itself. Always finite and within `0...maximumSeconds`, so it can safely be turned into a sleep duration.
    var duration: TimeInterval? {
        switch self {
        case .seconds(let value):
            guard value.isFinite, value <= Self.maximumSeconds else { return nil }
            return max(0, value)
        case .sticky:
            return nil
        }
    }

    /// `true` for a countdown that hides the toast at once (zero, negative); worth a warning, since it is almost certainly a mistake.
    var isNonPositive: Bool {
        if case .seconds(let value) = self { return value <= 0 }
        return false
    }
}
