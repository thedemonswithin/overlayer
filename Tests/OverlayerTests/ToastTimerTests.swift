//
//  ToastTimerTests.swift
//  Overlayer
//
//  Created by Evgeny Blinov on 05.11.2026.
//

import Foundation
import Testing
@testable import Overlayer

// Pure arithmetic over explicit timestamps, so no real time passes in these tests.
@Suite struct ToastTimerTests {
    @Test nonisolated func notStartedKeepsFullLifetime() {
        let timer = ToastTimer(total: 4)
        #expect(timer.remaining(at: 100) == 4)
        #expect(timer.progress(at: 100) == 1)
        #expect(!timer.isRunning)
    }

    @Test nonisolated func runningDrainsLinearly() {
        var timer = ToastTimer(total: 4)
        timer.resume(at: 10)
        #expect(timer.remaining(at: 11) == 3)
        #expect(timer.progress(at: 12) == 0.5)
        #expect(timer.remaining(at: 20) == 0, "never negative")
        #expect(timer.progress(at: 20) == 0)
    }

    @Test nonisolated func pauseFreezesElapsedTime() {
        var timer = ToastTimer(total: 4)
        timer.resume(at: 10)
        timer.pause(at: 11)
        #expect(timer.remaining(at: 50) == 3, "time while paused does not count")
        timer.resume(at: 50)
        #expect(timer.remaining(at: 52) == 1)
    }

    @Test nonisolated func repeatedPauseAndResumeAreIdempotent() {
        var timer = ToastTimer(total: 4)
        timer.resume(at: 10)
        timer.resume(at: 11)
        timer.pause(at: 12)
        timer.pause(at: 13)
        #expect(timer.elapsed(at: 99) == 2)
    }

    @Test nonisolated func stickyNeverDrains() {
        var timer = ToastTimer(total: nil)
        timer.resume(at: 0)
        #expect(timer.remaining(at: 1_000) == nil)
        #expect(timer.progress(at: 1_000) == 1)
    }

    @Test nonisolated func zeroLifetimeIsImmediatelyDone() {
        let timer = ToastTimer(total: 0)
        #expect(timer.remaining(at: 0) == 0)
        #expect(timer.progress(at: 0) == 0)
    }
}
