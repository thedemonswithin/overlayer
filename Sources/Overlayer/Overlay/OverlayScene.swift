//
//  OverlayScene.swift
//  Overlayer
//
//  Created by Evgeny Blinov on 10.06.2026.
//

import UIKit

// Locates the scene Overlayer attaches its windows to, and lets a window manager wait for one if none is active yet (e.g. a show during launch).
@MainActor enum OverlayScene {
    static var active: UIWindowScene? {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        return scenes.first { $0.activationState == .foregroundActive } ?? scenes.first
    }

    static func observeActivation(_ handler: @escaping (UIWindowScene) -> Void) -> NSObjectProtocol {
        NotificationCenter.default.addObserver(forName: UIScene.didActivateNotification, object: nil, queue: .main) { note in
            guard let scene = note.object as? UIWindowScene else { return }
            Task { @MainActor in handler(scene) }
        }
    }
}
