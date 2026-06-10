//
//  LoadingWindow.swift
//  Overlayer
//
//  Created by Evgeny Blinov on 10.06.2026.
//

import UIKit

// Window for the loading overlay. In blocking mode the hosted content is hit-testable and captures every touch; in non-blocking mode the content opts out of hit-testing (via SwiftUI's allowsHitTesting), so super.hitTest resolves to the window itself and we return nil to let the touch fall through to the app below.
final class LoadingWindow: UIWindow {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hit = super.hitTest(point, with: event)
        return hit === self ? nil : hit
    }
}
