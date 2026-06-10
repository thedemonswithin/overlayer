//
//  OverlayServiceTests.swift
//  Overlayer
//
//  Created by Evgeny Blinov on 10.06.2026.
//

import SwiftUI
import XCTest

@testable import Overlayer

@MainActor final class OverlayServiceTests: XCTestCase {
    private struct ProtoToast: ToastModel { let text: String }
    private struct ProtoLoading: LoadingModel {}

    func testImplConformsToOverlayProtocols() {
        let impl = OverlayServiceImpl()
        let overlay: any OverlayService = impl
        let toasts: any ToastPresenting = impl
        let loading: any LoadingPresenting = impl
        _ = overlay
        _ = toasts
        _ = loading
    }

    func testRegistrationAndConfiguration() {
        let impl = OverlayServiceImpl()
        impl.toastContainerConfiguration = ToastContainerConfiguration(maxVisibleCount: 5)
        impl.defaultToastConfiguration = ToastConfiguration(position: .top, lifetime: .sticky)
        impl.registerToast(ProtoToast.self) { model, _ in
            if model.text.isEmpty { Text("empty") } else { Text(model.text) }
        }
        impl.registerLoading(ProtoLoading.self) { _, context in
            Button("Cancel") { context.dismiss() }
        }
        XCTAssertEqual(impl.toastContainerConfiguration.maxVisibleCount, 5)
        XCTAssertEqual(impl.defaultToastConfiguration.position, .top)
    }
}
