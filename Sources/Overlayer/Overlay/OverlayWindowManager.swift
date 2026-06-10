//
//  OverlayWindowManager.swift
//  Overlayer
//
//  Created by Evgeny Blinov on 10.06.2026.
//

import SwiftUI
import UIKit

// Single manager for every overlay window. Lazily mounts a passthrough window for toasts (above alerts) and a loading window (above the app and its sheets, below system alerts; blocking by default, pass-through when configured), each created on first use. Adding a new overlay kind means adding one window here, not a parallel manager.
@MainActor final class OverlayWindowManager {
    private let toastPresenter: ToastPresenter
    private let loadingPresenter: LoadingPresenter
    private let relay = PassthroughRelay()
    private var toastWindow: PassthroughWindow?
    private var loadingWindow: UIWindow?
    private var sceneObserver: NSObjectProtocol?
    private var pendingToasts = false
    private var pendingLoading = false

    init(toastPresenter: ToastPresenter, loadingPresenter: LoadingPresenter) {
        self.toastPresenter = toastPresenter
        self.loadingPresenter = loadingPresenter
    }

    func activateToasts() {
        guard toastWindow == nil else { return }
        if let scene = OverlayScene.active {
            installToasts(in: scene)
        } else {
            pendingToasts = true
            observeSceneIfNeeded()
        }
    }

    func showLoading() {
        if loadingWindow == nil {
            if let scene = OverlayScene.active {
                installLoading(in: scene)
            } else {
                pendingLoading = true
                observeSceneIfNeeded()
            }
        }
        loadingWindow?.isHidden = false
    }

    func syncLoading() {
        loadingWindow?.isHidden = loadingPresenter.stack.isEmpty
    }

    private func observeSceneIfNeeded() {
        guard sceneObserver == nil else { return }
        sceneObserver = OverlayScene.observeActivation { [weak self] scene in
            guard let self else { return }
            if pendingToasts {
                installToasts(in: scene)
                pendingToasts = false
            }
            if pendingLoading {
                installLoading(in: scene)
                loadingWindow?.isHidden = false
                pendingLoading = false
            }
            if let sceneObserver {
                NotificationCenter.default.removeObserver(sceneObserver)
                self.sceneObserver = nil
            }
        }
    }

    private func installToasts(in scene: UIWindowScene) {
        guard toastWindow == nil else { return }
        let window = PassthroughWindow(windowScene: scene, relay: relay)
        window.windowLevel = UIWindow.Level(rawValue: UIWindow.Level.alert.rawValue + 1)
        window.backgroundColor = .clear
        let host = UIHostingController(rootView: ToastHostView(presenter: toastPresenter, relay: relay))
        host.view.backgroundColor = .clear
        window.rootViewController = host
        window.isHidden = false
        toastWindow = window
    }

    private func installLoading(in scene: UIWindowScene) {
        guard loadingWindow == nil else { return }
        let window = LoadingWindow(windowScene: scene)
        window.windowLevel = UIWindow.Level(rawValue: UIWindow.Level.normal.rawValue + 1)
        window.backgroundColor = .clear
        let host = UIHostingController(rootView: LoadingHostView(presenter: loadingPresenter))
        host.view.backgroundColor = .clear
        window.rootViewController = host
        window.isHidden = loadingPresenter.stack.isEmpty
        loadingWindow = window
    }
}
