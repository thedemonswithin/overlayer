//
//  LoadingPresenterTests.swift
//  Overlayer
//
//  Created by Evgeny Blinov on 10.06.2026.
//

import SwiftUI
import XCTest

@testable import Overlayer

@MainActor final class LoadingPresenterTests: XCTestCase {
    private struct DummyLoading: LoadingModel {}

    private func makeLoading(on presenter: LoadingPresenter) -> ActiveLoading {
        let id = LoadingID()
        let context = LoadingContext(id: id, presenter: presenter)
        return ActiveLoading(id: id, model: DummyLoading(), configuration: .default, context: context, content: AnyView(EmptyView()))
    }

    func testTopReflectsMostRecent() {
        let presenter = LoadingPresenter()
        let first = makeLoading(on: presenter)
        let second = makeLoading(on: presenter)
        presenter.present(first)
        presenter.present(second)
        XCTAssertEqual(presenter.stack.count, 2)
        XCTAssertEqual(presenter.top?.id, second.id)
    }

    func testHideRevealsPrevious() {
        let presenter = LoadingPresenter()
        let first = makeLoading(on: presenter)
        let second = makeLoading(on: presenter)
        presenter.present(first)
        presenter.present(second)
        presenter.hide(id: second.id)
        XCTAssertEqual(presenter.top?.id, first.id)
    }

    func testHideAllClearsStack() {
        let presenter = LoadingPresenter()
        presenter.present(makeLoading(on: presenter))
        presenter.present(makeLoading(on: presenter))
        presenter.hideAll()
        XCTAssertTrue(presenter.stack.isEmpty)
    }

    // Regression: a loading view dismissing itself (e.g. a Cancel button) must notify the window manager, otherwise the blocking window stays up over an empty stack.
    func testContextDismissRemovesAndNotifies() {
        let presenter = LoadingPresenter()
        var changes = 0
        presenter.onChange = { changes += 1 }
        let loading = makeLoading(on: presenter)
        presenter.present(loading)
        XCTAssertEqual(changes, 1)
        loading.context.dismiss()
        XCTAssertTrue(presenter.stack.isEmpty)
        XCTAssertEqual(changes, 2)
    }

    func testHideUnknownIdDoesNotNotify() {
        let presenter = LoadingPresenter()
        var changes = 0
        presenter.onChange = { changes += 1 }
        presenter.hide(id: LoadingID())
        XCTAssertEqual(changes, 0)
    }

    // The window manager hides the loading window only on this signal, so it must arrive after a removal.
    func testHideReportsSettled() {
        let presenter = LoadingPresenter()
        let loading = makeLoading(on: presenter)
        presenter.present(loading)
        let settled = expectation(description: "settled after hide")
        presenter.onSettled = {
            if presenter.stack.isEmpty { settled.fulfill() }
        }
        presenter.hide(id: loading.id)
        wait(for: [settled], timeout: 2)
    }
}
