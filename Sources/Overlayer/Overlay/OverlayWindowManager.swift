//
//  OverlayWindowManager.swift
//  Overlayer
//
//  Created by Evgeny Blinov on 10.06.2026.
//

import SwiftUI
import UIKit

// Single manager for every overlay window: a passthrough window for toasts (above alerts) and a loading window (above the app and its sheets, below system alerts; blocking by default, pass-through when configured). Each window is created on first use, shown while it has content, and hidden once its dismissal animation has played out. Adding a new overlay kind means adding one slot here, not a parallel manager.
@MainActor final class OverlayWindowManager {
    private let toastPresenter: ToastPresenter
    private let loadingPresenter: LoadingPresenter
    private let relay = PassthroughRelay()
    private var sceneObservers: [NSObjectProtocol] = []

    private lazy var toastSlot = OverlayWindowSlot(
        makeWindow: { [unowned self] scene in makeToastWindow(in: scene) },
        onInstall: { [unowned self] _ in syncToasts() }
    )
    private lazy var loadingSlot = OverlayWindowSlot(
        makeWindow: { [unowned self] scene in makeLoadingWindow(in: scene) },
        onInstall: { [unowned self] _ in syncLoading() }
    )

    init(toastPresenter: ToastPresenter, loadingPresenter: LoadingPresenter) {
        self.toastPresenter = toastPresenter
        self.loadingPresenter = loadingPresenter
        toastPresenter.onChange = { [weak self] in self?.syncToasts() }
        toastPresenter.onSettled = { [weak self] in self?.hideToastsIfIdle() }
        loadingPresenter.onChange = { [weak self] in self?.syncLoading() }
        loadingPresenter.onSettled = { [weak self] in self?.hideLoadingIfIdle() }
        sceneObservers = [
            OverlayScene.observe(UIScene.didActivateNotification) { [weak self] scene in
                self?.toastSlot.sceneDidActivate(scene)
                self?.loadingSlot.sceneDidActivate(scene)
            },
            OverlayScene.observe(UIScene.didDisconnectNotification) { [weak self] scene in
                self?.toastSlot.sceneDidDisconnect(scene)
                self?.loadingSlot.sceneDidDisconnect(scene)
            }
        ]
    }

    func activateToasts() {
        toastSlot.prepare()
    }

    func showLoading() {
        loadingSlot.prepare()
        syncLoading()
    }

    // MARK: - Toasts

    private func syncToasts() {
        guard let window = toastSlot.window, !toastPresenter.visible.isEmpty else { return }
        window.isHidden = false
    }

    // An empty toast window would still be the frontmost one, so it is taken off screen once the last toast has animated away.
    private func hideToastsIfIdle() {
        guard toastPresenter.visible.isEmpty else { return }
        toastSlot.window?.isHidden = true
    }

    // MARK: - Loading

    // Keeps the loading window in step with the presenter's stack. Called on every stack change and after the window is installed.
    private func syncLoading() {
        guard let window = loadingSlot.window else { return }
        guard let top = loadingPresenter.top else {
            // Stop blocking at once; the window itself stays until the removal animation has played (see hideLoadingIfIdle).
            window.isBlocking = false
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

    private func hideLoadingIfIdle() {
        guard loadingPresenter.stack.isEmpty else { return }
        loadingSlot.window?.isHidden = true
    }

    // MARK: - Window factories

    private func makeToastWindow(in scene: UIWindowScene) -> PassthroughWindow {
        let window = PassthroughWindow(windowScene: scene, relay: relay)
        window.windowLevel = UIWindow.Level(rawValue: UIWindow.Level.alert.rawValue + 1)
        window.backgroundColor = .clear
        let host = OverlayHostingController(rootView: ToastHostView(presenter: toastPresenter, relay: relay))
        host.view.backgroundColor = .clear
        window.rootViewController = host
        window.isHidden = true
        return window
    }

    private func makeLoadingWindow(in scene: UIWindowScene) -> LoadingWindow {
        let window = LoadingWindow(windowScene: scene)
        window.windowLevel = UIWindow.Level(rawValue: UIWindow.Level.normal.rawValue + 1)
        window.backgroundColor = .clear
        window.isBlocking = false
        let host = OverlayHostingController(rootView: LoadingHostView(presenter: loadingPresenter))
        host.view.backgroundColor = .clear
        window.rootViewController = host
        window.isHidden = true
        return window
    }
}
