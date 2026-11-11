//
//  ToastConfigurationTests.swift
//  Overlayer
//
//  Created by Evgeny Blinov on 10.06.2026.
//

import Foundation
import Testing
@testable import Overlayer

// Configuration values are plain Sendable data, usable off the main actor.
@Suite struct ToastConfigurationTests {
    @Test nonisolated func toastDefaults() {
        let configuration = ToastConfiguration.default
        #expect(configuration.position == .bottom)
        #expect(configuration.lifetime == .seconds(4))
        #expect(!configuration.isSwipeToDismissEnabled)
        #expect(!configuration.isTapToPauseEnabled)
        #expect(configuration.isHoldToPauseEnabled)
        #expect(configuration.showsCloseButton)
        #expect(configuration.showsProgressBar)
    }

    @Test nonisolated func containerDefaults() {
        let container = ToastContainerConfiguration.default
        #expect(container.maxVisibleCount == 3)
        #expect(container.spacing == 8)
    }

    @Test(arguments: [
        (ToastLifetime.seconds(3), 3.0),
        (.sticky, nil),
        (.seconds(.infinity), nil),
        (.seconds(.nan), nil),
        (.seconds(.greatestFiniteMagnitude), nil),
        (.seconds(ToastLifetime.maximumSeconds + 1), nil),
        (.seconds(ToastLifetime.maximumSeconds), ToastLifetime.maximumSeconds),
        (.seconds(0), 0),
        (.seconds(-5), 0)
    ] as [(ToastLifetime, TimeInterval?)])
    nonisolated func lifetimeDuration(lifetime: ToastLifetime, expected: TimeInterval?) {
        #expect(lifetime.duration == expected)
    }

    @Test(arguments: [(ToastLifetime.seconds(0), true), (.seconds(-1), true), (.seconds(1), false), (.sticky, false)])
    nonisolated func nonPositiveLifetimeIsFlagged(lifetime: ToastLifetime, expected: Bool) {
        #expect(lifetime.isNonPositive == expected)
    }
}
