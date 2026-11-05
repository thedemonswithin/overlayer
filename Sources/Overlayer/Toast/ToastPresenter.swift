//
//  ToastPresenter.swift
//  Overlayer
//
//  Created by Evgeny Blinov on 10.06.2026.
//

import Combine
import SwiftUI

final class ToastPresenter: ObservableObject {
    @Published private(set) var visible: [ActiveToast] = [] {
        didSet { onChange?() }
    }
    @Published var containerConfiguration: ToastContainerConfiguration = .default {
        // A raised limit frees slots immediately; without this, queued toasts would wait for the next dismissal.
        didSet { pumpQueue() }
    }

    /// Called synchronously whenever the visible set changes.
    var onChange: (() -> Void)?
    /// Called once the animation of a visible-set change has played out.
    var onSettled: (() -> Void)?

    private var queue: [ActiveToast] = []
    /// One sleeping task per running auto-dismiss toast; nothing ticks.
    private var expiryTasks: [ToastID: Task<Void, Never>] = [:]

    func present(_ toast: ActiveToast) {
        guard visible.count < containerConfiguration.maxVisibleCount else {
            queue.append(toast)
            return
        }
        show(toast)
    }

    func dismiss(id: ToastID) {
        cancelExpiry(of: id)
        if let index = visible.firstIndex(where: { $0.id == id }) {
            animate {
                _ = visible.remove(at: index)
            }
            pumpQueue()
        } else {
            queue.removeAll { $0.id == id }
        }
    }

    func dismissAll() {
        expiryTasks.values.forEach { $0.cancel() }
        expiryTasks.removeAll()
        queue.removeAll()
        guard !visible.isEmpty else { return }
        animate {
            visible.removeAll()
        }
    }

    func pause(id: ToastID) {
        guard let context = visible.first(where: { $0.id == id })?.context, !context.isPaused else { return }
        context.timer.pause(at: context.clock())
        context.isPaused = true
        cancelExpiry(of: id)
    }

    func resume(id: ToastID) {
        guard let toast = visible.first(where: { $0.id == id }), toast.context.isPaused else { return }
        toast.context.isPaused = false
        startLifetime(of: toast)
    }

    // The lifetime starts when a toast becomes visible, so a queued toast keeps its full duration.
    private func show(_ toast: ActiveToast) {
        animate {
            visible.append(toast)
        }
        toast.configuration.haptic.trigger()
        startLifetime(of: toast)
    }

    private func pumpQueue() {
        while let next = queue.first, visible.count < containerConfiguration.maxVisibleCount {
            queue.removeFirst()
            show(next)
        }
    }

    private func animate(_ body: () -> Void) {
        OverlayAnimation.perform(containerConfiguration.animation, body) { [weak self] in self?.onSettled?() }
    }

    private func startLifetime(of toast: ActiveToast) {
        let context = toast.context
        context.timer.resume(at: context.clock())
        cancelExpiry(of: toast.id)
        guard let remaining = context.timer.remaining(at: context.clock()) else { return }
        let id = toast.id
        expiryTasks[id] = Task { [weak self] in
            try? await Task.sleep(nanoseconds: UInt64(remaining * 1_000_000_000))
            guard !Task.isCancelled else { return }
            self?.expiryTasks[id] = nil
            self?.dismiss(id: id)
        }
    }

    private func cancelExpiry(of id: ToastID) {
        expiryTasks.removeValue(forKey: id)?.cancel()
    }
}
