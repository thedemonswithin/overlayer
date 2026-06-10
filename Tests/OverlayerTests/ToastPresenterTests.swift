//
//  ToastPresenterTests.swift
//  Overlayer
//
//  Created by Evgeny Blinov on 10.06.2026.
//

import SwiftUI
import XCTest

@testable import Overlayer

@MainActor final class ToastPresenterTests: XCTestCase {
    private struct DummyModel: ToastModel {}

    private func makeToast(on presenter: ToastPresenter) -> ActiveToast {
        let configuration = ToastConfiguration(lifetime: .sticky)
        let id = ToastID()
        let context = ToastContext(id: id, configuration: configuration, presenter: presenter)
        return ActiveToast(id: id, model: DummyModel(), configuration: configuration, context: context, content: AnyView(EmptyView()))
    }

    private func makePresenter(maxVisible: Int) -> ToastPresenter {
        let presenter = ToastPresenter()
        presenter.containerConfiguration = ToastContainerConfiguration(maxVisibleCount: maxVisible)
        return presenter
    }

    func testShowsUpToLimitAndQueuesTheRest() {
        let presenter = makePresenter(maxVisible: 2)
        (0..<3).map { _ in makeToast(on: presenter) }.forEach { presenter.present($0) }
        XCTAssertEqual(presenter.visible.count, 2)
    }

    func testDismissPromotesQueuedToast() {
        let presenter = makePresenter(maxVisible: 2)
        let toasts = (0..<3).map { _ in makeToast(on: presenter) }
        toasts.forEach { presenter.present($0) }
        presenter.dismiss(id: toasts[0].id)
        XCTAssertEqual(presenter.visible.count, 2)
        XCTAssertTrue(presenter.visible.contains { $0.id == toasts[2].id })
    }

    func testDismissAllClearsVisibleAndQueue() {
        let presenter = makePresenter(maxVisible: 2)
        (0..<4).map { _ in makeToast(on: presenter) }.forEach { presenter.present($0) }
        presenter.dismissAll()
        XCTAssertTrue(presenter.visible.isEmpty)
    }

    func testPauseAndResumeToggleContextState() {
        let presenter = makePresenter(maxVisible: 3)
        let toast = makeToast(on: presenter)
        presenter.present(toast)
        presenter.pause(id: toast.id)
        XCTAssertTrue(toast.context.isPaused)
        presenter.resume(id: toast.id)
        XCTAssertFalse(toast.context.isPaused)
    }
}
