//
//  OverlayScene.swift
//  Overlayer
//
//  Created by Evgeny Blinov on 10.06.2026.
//

import UIKit

// Locates the scene Overlayer attaches its windows to and reports scene lifecycle events, so windows can be installed once a scene exists and moved off a scene that went away.
enum OverlayScene {
    /// Best scene to show overlays in: foreground-active first, then foreground-inactive, then any attached one.
    static var active: UIWindowScene? { active(excluding: nil) }

    static func active(excluding excluded: UIScene?) -> UIWindowScene? {
        let scenes = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .filter { $0 !== excluded && $0.activationState != .unattached }
        return scenes.first { $0.activationState == .foregroundActive }
            ?? scenes.first { $0.activationState == .foregroundInactive }
            ?? scenes.first
    }

    /// Whether a window attached to `scene` can currently be seen.
    static func isUsable(_ scene: UIWindowScene?) -> Bool {
        guard let scene else { return false }
        return scene.activationState == .foregroundActive || scene.activationState == .foregroundInactive
    }

    static func observe(_ name: Notification.Name, _ handler: @escaping @MainActor @Sendable (UIWindowScene) -> Void) -> any NSObjectProtocol {
        NotificationCenter.default.addObserver(forName: name, object: nil, queue: .main) { note in
            guard let scene = note.object as? UIWindowScene else { return }
            // Delivered on the main queue, so the main actor can be assumed rather than hopping through a Task.
            MainActor.assumeIsolated { handler(scene) }
        }
    }
}
