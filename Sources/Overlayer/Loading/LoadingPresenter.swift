//
//  LoadingPresenter.swift
//  Overlayer
//
//  Created by Evgeny Blinov on 10.06.2026.
//

import SwiftUI
import Combine

/// Owns the stack of active loading overlays. The most recent one is displayed and the blocker stays up while the stack is non-empty, which supports nested loading. Pure state, so it is unit-testable without any UI.
@MainActor final class LoadingPresenter: ObservableObject {
    @Published private(set) var stack: [ActiveLoading] = []
    var top: ActiveLoading? { stack.last }
    
    func present(_ loading: ActiveLoading) {
        withAnimation(loading.configuration.animation) {
            stack.append(loading)
        }
    }
    
    func hide(id: LoadingID) {
        guard let index = stack.firstIndex(where: { $0.id == id }) else { return }
        let animation = stack[index].configuration.animation
        withAnimation(animation) {
            _ = stack.remove(at: index)
        }
    }
    
    func hideAll() {
        let animation = stack.last?.configuration.animation ?? .default
        withAnimation(animation) {
            stack.removeAll()
        }
    }
}
