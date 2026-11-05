//
//  OverlayHostingController.swift
//  Overlayer
//
//  Created by Evgeny Blinov on 05.11.2026.
//

import SwiftUI
import UIKit

/// Marks windows owned by Overlayer, so appearance forwarding can tell them apart from the app's own windows.
protocol OverlayWindow: UIWindow {}

// Hosting controller for overlay windows. An overlay window sits above the app, so UIKit asks its root controller for the status bar, home indicator and orientation preferences; a bare UIHostingController would override the app's choices while a toast or loader is up. This one forwards those questions to the app's visible controller.
final class OverlayHostingController<Content: View>: UIHostingController<Content> {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        appearanceSource(\.childForStatusBarStyle)?.preferredStatusBarStyle ?? super.preferredStatusBarStyle
    }

    override var prefersStatusBarHidden: Bool {
        appearanceSource(\.childForStatusBarHidden)?.prefersStatusBarHidden ?? super.prefersStatusBarHidden
    }

    override var prefersHomeIndicatorAutoHidden: Bool {
        appearanceSource(\.childForHomeIndicatorAutoHidden)?.prefersHomeIndicatorAutoHidden ?? super.prefersHomeIndicatorAutoHidden
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        OverlayAppearance.appController(below: view.window)?.supportedInterfaceOrientations ?? super.supportedInterfaceOrientations
    }

    private func appearanceSource(_ child: KeyPath<UIViewController, UIViewController?>) -> UIViewController? {
        OverlayAppearance.appController(below: view.window).map { OverlayAppearance.resolve($0, child: child) }
    }
}

// Finds the app controller whose appearance preferences an overlay window should mirror.
enum OverlayAppearance {
    /// The topmost presented controller of the app's own normal-level window in the overlay's scene (key window first).
    static func appController(below overlayWindow: UIWindow?) -> UIViewController? {
        guard let scene = overlayWindow?.windowScene else { return nil }
        // Only normal-level windows: other overlay libraries' windows are never consulted, which also rules out forwarding loops between overlays.
        let appWindows = scene.windows.filter { !($0 is any OverlayWindow) && !$0.isHidden && $0.windowLevel == .normal }
        let appWindow = appWindows.first(where: \.isKeyWindow) ?? appWindows.first
        return appWindow?.rootViewController.map(topmost)
    }

    /// Walks the presentation chain while each presented controller takes over status bar appearance (full-screen, or one that captures it explicitly).
    static func topmost(from root: UIViewController) -> UIViewController {
        var current = root
        while let presented = current.presentedViewController, !presented.isBeingDismissed, capturesAppearance(presented) {
            current = presented
        }
        return current
    }

    /// Follows `childForStatusBarStyle`-style delegation to the controller that actually decides.
    static func resolve(_ controller: UIViewController, child: KeyPath<UIViewController, UIViewController?>) -> UIViewController {
        var current = controller
        var hops = 0
        while let next = current[keyPath: child], next !== current, hops < 32 {
            current = next
            hops += 1
        }
        return current
    }

    private static func capturesAppearance(_ controller: UIViewController) -> Bool {
        switch controller.modalPresentationStyle {
        case .fullScreen, .overFullScreen: return true
        default: return controller.modalPresentationCapturesStatusBarAppearance
        }
    }
}
