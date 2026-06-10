//
//  ToastHostView.swift
//  Overlayer
//
//  Created by Evgeny Blinov on 10.06.2026.
//

import SwiftUI

struct ToastHostView: View {
    @ObservedObject var presenter: ToastPresenter
    let relay: PassthroughRelay

    var body: some View {
        let configuration = presenter.containerConfiguration
        ZStack {
            container(for: .top, configuration: configuration)
            container(for: .center, configuration: configuration)
            container(for: .bottom, configuration: configuration)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(configuration.edgeInsets)
        .onPreferenceChange(ToastFramePreferenceKey.self) { relay.interactiveFrames = $0 }
    }

    private func container(for position: ToastPosition, configuration: ToastContainerConfiguration) -> some View {
        VStack(spacing: configuration.spacing) {
            ForEach(toasts(at: position)) { toast in
                ToastItemView(toast: toast)
                    .frame(maxWidth: .infinity)
                    .background {
                        GeometryReader { proxy in
                            Color.clear.preference(
                                key: ToastFramePreferenceKey.self,
                                value: [toast.id: proxy.frame(in: .global)]
                            )
                        }
                    }
                    .transition(transition(for: position))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignment(for: position))
    }

    private func toasts(at position: ToastPosition) -> [ActiveToast] {
        let filtered = presenter.visible.filter { $0.configuration.position == position }
        return position == .top ? Array(filtered.reversed()) : filtered
    }

    private func alignment(for position: ToastPosition) -> Alignment {
        switch position {
        case .top: return .top
        case .bottom: return .bottom
        case .center: return .center
        }
    }

    private func transition(for position: ToastPosition) -> AnyTransition {
        switch position {
        case .top: return .move(edge: .top).combined(with: .opacity)
        case .bottom: return .move(edge: .bottom).combined(with: .opacity)
        case .center: return .scale(scale: 0.85).combined(with: .opacity)
        }
    }
}

private extension ToastHostView {
    struct ToastFramePreferenceKey: PreferenceKey {
        static var defaultValue: [ToastID: CGRect] = [:]

        static func reduce(value: inout [ToastID: CGRect], nextValue: () -> [ToastID: CGRect]) {
            value.merge(nextValue()) { _, latest in latest }
        }
    }
}
