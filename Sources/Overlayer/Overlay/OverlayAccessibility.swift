//
//  OverlayAccessibility.swift
//  Overlayer
//
//  Created by Evgeny Blinov on 05.11.2026.
//

import Foundation
import UIKit

// VoiceOver plumbing shared by toasts and loading.
enum OverlayAccessibility {
    /// Bundle holding the package's localized strings.
    static var resources: Bundle { .module }

    /// Speaks `text` without moving VoiceOver focus, which suits transient overlays like toasts.
    static func announce(_ text: String?) {
        guard let text, !text.isEmpty else { return }
        UIAccessibility.post(notification: .announcement, argument: text)
    }

    /// Tells VoiceOver the screen changed so it re-reads the frontmost content (a blocking loader appeared or went away).
    static func screenChanged() {
        UIAccessibility.post(notification: .screenChanged, argument: nil)
    }
}
