//
//  OverlayAnimation.swift
//  Overlayer
//
//  Created by Evgeny Blinov on 05.11.2026.
//

import SwiftUI

// Runs a state change inside `withAnimation` and reports when the animation has played out, so an overlay window can be hidden only after its content has finished animating away.
enum OverlayAnimation {
    /// iOS 16 has no animation completion, so the settle callback fires after this fixed delay instead. Long enough for the default eases and springs.
    static let legacySettleDelay: TimeInterval = 0.8

    static func perform(_ animation: Animation?, _ body: () -> Void, settled: @escaping @MainActor () -> Void) {
        if #available(iOS 17.0, *) {
            withAnimation(animation, completionCriteria: .removed, body) {
                MainActor.assumeIsolated { settled() }
            }
        } else {
            withAnimation(animation, body)
            Task {
                try? await Task.sleep(nanoseconds: UInt64(legacySettleDelay * 1_000_000_000))
                settled()
            }
        }
    }
}
