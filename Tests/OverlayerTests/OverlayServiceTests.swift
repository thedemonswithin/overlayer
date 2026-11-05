//
//  OverlayServiceTests.swift
//  Overlayer
//
//  Created by Evgeny Blinov on 10.06.2026.
//

import SwiftUI
import Testing
@testable import Overlayer

@Suite struct OverlayServiceTests {
    private struct ProtoToast: ToastModel { let text: String }
    private struct ProtoLoading: LoadingModel {}

    @Test func implConformsToOverlayProtocols() {
        let impl = OverlayServiceImpl()
        let overlay: any OverlayService = impl
        let toasts: any ToastPresenting = impl
        let loading: any LoadingPresenting = impl
        #expect(overlay === toasts && toasts === loading)
    }

    @Test func registrationAndConfiguration() {
        let impl = OverlayServiceImpl()
        impl.toastContainerConfiguration = ToastContainerConfiguration(maxVisibleCount: 5)
        impl.defaultToastConfiguration = ToastConfiguration(position: .top, lifetime: .sticky)
        impl.registerToast(ProtoToast.self) { model, _ in
            if model.text.isEmpty { Text("empty") } else { Text(model.text) }
        }
        impl.registerLoading(ProtoLoading.self) { _, context in
            Button("Cancel") { context.dismiss() }
        }
        #expect(impl.toastContainerConfiguration.maxVisibleCount == 5)
        #expect(impl.defaultToastConfiguration.position == .top)
    }

    // The shared instance is reachable from a nonisolated context (e.g. a DI container factory).
    @Test nonisolated func sharedIsAvailableNonisolated() {
        let shared: OverlayServiceImpl = OverlayServiceImpl.shared
        #expect(shared === OverlayServiceImpl.shared)
    }
}
