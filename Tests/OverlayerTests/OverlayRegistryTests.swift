//
//  OverlayRegistryTests.swift
//  Overlayer
//
//  Created by Evgeny Blinov on 10.06.2026.
//

import SwiftUI
import XCTest

@testable import Overlayer

@MainActor final class OverlayRegistryTests: XCTestCase {
    private struct ToastA: ToastModel {}
    private struct ToastB: ToastModel {}
    private struct LoadingA: LoadingModel {}

    func testResolvesRegisteredToastModel() {
        let registry = OverlayRegistry<ToastContext>()
        registry.register(ToastA.self) { _, _ in AnyView(EmptyView()) }
        let context = ToastContext(id: ToastID(), configuration: .default, presenter: ToastPresenter())
        XCTAssertNotNil(registry.makeView(for: ToastA(), context: context))
        XCTAssertNil(registry.makeView(for: ToastB(), context: context))
    }

    func testResolvesRegisteredLoadingModel() {
        let registry = OverlayRegistry<LoadingContext>()
        registry.register(LoadingA.self) { _, _ in AnyView(EmptyView()) }
        let context = LoadingContext(id: LoadingID(), presenter: LoadingPresenter())
        XCTAssertNotNil(registry.makeView(for: LoadingA(), context: context))
    }
}
