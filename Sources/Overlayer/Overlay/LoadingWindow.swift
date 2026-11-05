//
//  LoadingWindow.swift
//  Overlayer
//
//  Created by Evgeny Blinov on 10.06.2026.
//

import UIKit

// Window for the loading overlay. In blocking mode it captures every touch (the backdrop swallows them, while the loading view's own controls still work); when the current overlay is non-blocking, hitTest returns nil so touches fall straight through to the app below. `isBlocking` is kept in sync with the top overlay by OverlayWindowManager — deciding at the window level is robust against UIHostingController reporting its root view as the hit for every point.
final class LoadingWindow: UIWindow, OverlayWindow {
    var isBlocking = true

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        isBlocking ? super.hitTest(point, with: event) : nil
    }
}
