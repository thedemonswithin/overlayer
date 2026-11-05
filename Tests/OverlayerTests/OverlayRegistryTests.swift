//
//  OverlayRegistryTests.swift
//  Overlayer
//
//  Created by Evgeny Blinov on 10.06.2026.
//

import SwiftUI
import Testing
@testable import Overlayer

@Suite struct OverlayRegistryTests {
    private struct ToastA: ToastModel {}
    private struct ToastB: ToastModel {}
    private struct LoadingA: LoadingModel {}

    @Test func resolvesRegisteredToastModel() {
        let registry = OverlayRegistry<ToastContext>()
        registry.register(ToastA.self) { _, _ in AnyView(EmptyView()) }
        let context = ToastContext(id: ToastID(), configuration: .default, presenter: ToastPresenter())
        #expect(registry.makeView(for: ToastA(), context: context) != nil)
        #expect(registry.makeView(for: ToastB(), context: context) == nil)
    }

    @Test func resolvesRegisteredLoadingModel() {
        let registry = OverlayRegistry<LoadingContext>()
        registry.register(LoadingA.self) { _, _ in AnyView(EmptyView()) }
        let context = LoadingContext(id: LoadingID(), presenter: LoadingPresenter())
        #expect(registry.makeView(for: LoadingA(), context: context) != nil)
    }
}
