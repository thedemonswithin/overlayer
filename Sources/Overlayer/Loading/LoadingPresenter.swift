//
//  LoadingPresenter.swift
//  Overlayer
//
//  Created by Evgeny Blinov on 10.06.2026.
//

import SwiftUI
import Combine

/// Owns the stack of active loading overlays. The most recent one is displayed and the blocker stays up while the stack is non-empty, which supports nested loading. Pure state, so it is unit-testable without any UI.
final class LoadingPresenter: ObservableObject {
    @Published private(set) var stack: [ActiveLoading] = [] {
        didSet { onChange?() }
    }
    var top: ActiveLoading? { stack.last }
    /// Called synchronously on every stack change.
    var onChange: (() -> Void)?
    /// Called once the animation of a stack change has played out.
    var onSettled: (() -> Void)?

    func present(_ loading: ActiveLoading) {
        animate(loading.configuration.animation) {
            stack.append(loading)
        }
    }

    func hide(id: LoadingID) {
        guard let index = stack.firstIndex(where: { $0.id == id }) else { return }
        animate(stack[index].configuration.animation) {
            _ = stack.remove(at: index)
        }
    }

    func hideAll() {
        guard !stack.isEmpty else { return }
        animate(stack.last?.configuration.animation ?? .default) {
            stack.removeAll()
        }
    }

    private func animate(_ animation: Animation, _ body: () -> Void) {
        OverlayAnimation.perform(animation, body) { [weak self] in self?.onSettled?() }
    }
}
