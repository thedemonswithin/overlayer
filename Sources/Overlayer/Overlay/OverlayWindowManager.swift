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
    private var loadingWindow: LoadingWindow?
    private var sceneObserver: NSObjectProtocol?
    private var pendingToasts = false
    private var pendingLoading = false
    private var hideLoadingTask: Task<Void, Never>?
    /// How long the loading window stays visible (non-blocking) after the stack empties, so the dismissal animation can finish. Covers the default 0.2s ease plus typical springs.
    private static let loadingHideDelay: TimeInterval = 0.5

    init(toastPresenter: ToastPresenter, loadingPresenter: LoadingPresenter) {
        self.toastPresenter = toastPresenter
        self.loadingPresenter = loadingPresenter
        loadingPresenter.onChange = { [weak self] in self?.syncLoading() }
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
        guard loadingWindow == nil else {
            syncLoading()
            return
        }
        if let scene = OverlayScene.active {
            installLoading(in: scene)
        } else {
            pendingLoading = true
            observeSceneIfNeeded()
        }
    }

    // Keeps the loading window in step with the presenter's stack. Called on every stack change (via `onChange`) and after the window is installed.
    func syncLoading() {
        hideLoadingTask?.cancel()
        hideLoadingTask = nil
        guard let window = loadingWindow else { return }

        guard let top = loadingPresenter.top else {
            // Stop blocking at once, but keep the window on screen until the removal animation has played; hiding it synchronously would cut the fade-out.
            window.isBlocking = false
            hideLoadingTask = Task { @MainActor [weak self] in
                try? await Task.sleep(nanoseconds: UInt64(Self.loadingHideDelay * 1_000_000_000))
                guard let self, !Task.isCancelled, self.loadingPresenter.stack.isEmpty else { return }
                self.loadingWindow?.isHidden = true
                self.hideLoadingTask = nil
            }
            return
        }

        let isBlocking = top.configuration.isBlocking
        let wasBlockingOnScreen = !window.isHidden && window.isBlocking
        window.isBlocking = isBlocking
        window.isHidden = false
        if isBlocking, !wasBlockingOnScreen {
            // The keyboard window sits above the loading window, so a focused field beneath a blocking loader would stay editable; drop focus when blocking begins.
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
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
        window.isBlocking = false
        let host = UIHostingController(rootView: LoadingHostView(presenter: loadingPresenter))
        host.view.backgroundColor = .clear
        window.rootViewController = host
        window.isHidden = true
        loadingWindow = window
        // Visibility, blocking and keyboard dismissal are all decided in one place.
        syncLoading()
    }
}
