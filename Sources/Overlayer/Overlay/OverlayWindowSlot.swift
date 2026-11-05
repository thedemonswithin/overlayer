//
//  OverlayWindowSlot.swift
//  Overlayer
//
//  Created by Evgeny Blinov on 05.11.2026.
//

import UIKit

// Lifecycle of one overlay window: created lazily on the best scene (or as soon as one activates, for a show during launch), and moved to another scene when its own one is disconnected or no longer in the foreground.
@MainActor final class OverlayWindowSlot<Window: UIWindow> {
    private let makeWindow: (UIWindowScene) -> Window
    private let onInstall: (Window) -> Void
    private(set) var window: Window?
    private var isAwaitingScene = false

    init(makeWindow: @escaping (UIWindowScene) -> Window, onInstall: @escaping (Window) -> Void) {
        self.makeWindow = makeWindow
        self.onInstall = onInstall
    }

    /// Makes sure the window exists and sits on a visible scene. Without any scene yet, installation waits for the next activation.
    func prepare() {
        if let window {
            relocateIfUnusable(window, to: OverlayScene.active)
        } else if let scene = OverlayScene.active {
            install(in: scene)
        } else {
            isAwaitingScene = true
        }
    }

    func sceneDidActivate(_ scene: UIWindowScene) {
        if let window {
            relocateIfUnusable(window, to: scene)
        } else if isAwaitingScene {
            install(in: scene)
        }
    }

    func sceneDidDisconnect(_ scene: UIWindowScene) {
        guard let window, window.windowScene == nil || window.windowScene === scene else { return }
        if let replacement = OverlayScene.active(excluding: scene) {
            window.windowScene = replacement
        }
    }

    // Moves the window only when it cannot be seen where it is, so on iPad an overlay does not jump between two foreground scenes as focus changes.
    private func relocateIfUnusable(_ window: Window, to scene: UIWindowScene?) {
        guard let scene, scene !== window.windowScene, !OverlayScene.isUsable(window.windowScene) else { return }
        window.windowScene = scene
    }

    private func install(in scene: UIWindowScene) {
        isAwaitingScene = false
        let window = makeWindow(scene)
        self.window = window
        onInstall(window)
    }
}
