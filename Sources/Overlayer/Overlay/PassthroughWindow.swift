//
//  PassthroughWindow.swift
//  Overlayer
//
//  Created by Evgeny Blinov on 10.06.2026.
//

import UIKit

/// Relay shared between the SwiftUI host and its window: the host reports the on-screen frame of every toast card (in window coordinates) and the window consults it to decide which touches to capture. Mutated and read on the main thread only.
final class PassthroughRelay: @unchecked Sendable {
    var interactiveFrames: [ToastID: CGRect] = [:]
    
    func capturesTouch(at point: CGPoint) -> Bool {
        interactiveFrames.values.contains { $0.contains(point) }
    }
}
/// Window that captures a touch only when it lands on a toast card, and lets every other touch fall through to the app below — so the rest of the interface stays fully interactive while toasts still receive their own taps, buttons, and gestures. Relying on the reported card frames is robust against `UIHostingController` returning its root view for every point.
final class PassthroughWindow: UIWindow {
    private let relay: PassthroughRelay
    
    init(windowScene: UIWindowScene, relay: PassthroughRelay) {
        self.relay = relay
        super.init(windowScene: windowScene)
    }
    
    @available(*, unavailable) required init?(coder: NSCoder) { fatalError("init(coder:) is not supported") }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard relay.capturesTouch(at: point) else { return nil }
        return super.hitTest(point, with: event)
    }
}
