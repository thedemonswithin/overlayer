//
//  ToastTimer.swift
//  Overlayer
//
//  Created by Evgeny Blinov on 05.11.2026.
//

import Foundation

/// Monotonic time source for toast lifetimes: seconds since boot, unaffected by wall-clock changes.
nonisolated enum OverlayClock {
    static func now() -> TimeInterval { ProcessInfo.processInfo.systemUptime }
}

// Lifetime bookkeeping of one toast as pure arithmetic over timestamps: nothing ticks, the remaining time and progress are derived from "now" whenever someone asks. Pausing folds the running span into `accumulated`.
nonisolated struct ToastTimer: Sendable, Equatable {
    /// Total visible duration, or `nil` for a sticky toast.
    let total: TimeInterval?
    private(set) var accumulated: TimeInterval = 0
    private(set) var runningSince: TimeInterval?

    init(total: TimeInterval?) {
        self.total = total
    }

    var isRunning: Bool { runningSince != nil }

    func elapsed(at now: TimeInterval) -> TimeInterval {
        accumulated + (runningSince.map { max(0, now - $0) } ?? 0)
    }

    /// Time left before auto-dismissal, or `nil` for a sticky toast.
    func remaining(at now: TimeInterval) -> TimeInterval? {
        total.map { max(0, $0 - elapsed(at: now)) }
    }

    /// Remaining fraction of the lifetime, draining from 1 to 0; always 1 for a sticky toast.
    func progress(at now: TimeInterval) -> Double {
        guard let total else { return 1 }
        guard total > 0 else { return 0 }
        return min(1, max(0, 1 - elapsed(at: now) / total))
    }

    mutating func resume(at now: TimeInterval) {
        guard runningSince == nil else { return }
        runningSince = now
    }

    mutating func pause(at now: TimeInterval) {
        guard let start = runningSince else { return }
        accumulated += max(0, now - start)
        runningSince = nil
    }
}
