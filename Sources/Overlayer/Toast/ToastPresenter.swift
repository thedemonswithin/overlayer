//
//  ToastPresenter.swift
//  Overlayer
//
//  Created by Evgeny Blinov on 10.06.2026.
//

import Combine
import SwiftUI

@MainActor final class ToastPresenter: ObservableObject {
    @Published private(set) var visible: [ActiveToast] = []
    @Published var containerConfiguration: ToastContainerConfiguration = .default

    private var queue: [ActiveToast] = []
    private var tickTask: Task<Void, Never>?
    private let tickInterval: TimeInterval = 1.0 / 60.0

    func present(_ toast: ActiveToast) {
        guard visible.count < containerConfiguration.maxVisibleCount else {
            queue.append(toast)
            return
        }
        withAnimation(containerConfiguration.animation) {
            visible.append(toast)
        }
        toast.configuration.haptic.trigger()
        startTickingIfNeeded()
    }

    func dismiss(id: ToastID) {
        if let index = visible.firstIndex(where: { $0.id == id }) {
            withAnimation(containerConfiguration.animation) {
                _ = visible.remove(at: index)
            }
            pumpQueue()
        } else {
            queue.removeAll { $0.id == id }
        }
    }

    func dismissAll() {
        queue.removeAll()
        withAnimation(containerConfiguration.animation) {
            visible.removeAll()
        }
    }

    func pause(id: ToastID) {
        guard let toast = visible.first(where: { $0.id == id }), !toast.isPaused else { return }
        toast.isPaused = true
        toast.context.isPaused = true
    }

    func resume(id: ToastID) {
        guard let toast = visible.first(where: { $0.id == id }), toast.isPaused else { return }
        toast.isPaused = false
        toast.context.isPaused = false
    }

    private func pumpQueue() {
        while let next = queue.first, visible.count < containerConfiguration.maxVisibleCount {
            queue.removeFirst()
            withAnimation(containerConfiguration.animation) {
                visible.append(next)
            }
            next.configuration.haptic.trigger()
        }
        startTickingIfNeeded()
    }

    private func startTickingIfNeeded() {
        guard tickTask == nil, visible.contains(where: { $0.totalLifetime != nil }) else { return }
        tickTask = Task { @MainActor [weak self] in
            var last = Date.now
            while true {
                let interval = self?.tickInterval ?? 0.05
                try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
                guard let self, !Task.isCancelled else { return }
                guard self.visible.contains(where: { $0.totalLifetime != nil }) else {
                    self.tickTask = nil
                    return
                }
                let now = Date.now
                self.tick(delta: now.timeIntervalSince(last))
                last = now
            }
        }
    }

    private func tick(delta: TimeInterval) {
        var expired: [ToastID] = []
        for toast in visible {
            guard let total = toast.totalLifetime, !toast.isPaused else { continue }
            toast.elapsed += delta
            toast.context.progress = max(0, 1 - toast.elapsed / total)
            if toast.elapsed >= total {
                expired.append(toast.id)
            }
        }
        for id in expired {
            dismiss(id: id)
        }
    }
}
