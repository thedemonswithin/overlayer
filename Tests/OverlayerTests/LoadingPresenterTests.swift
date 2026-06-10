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
}
