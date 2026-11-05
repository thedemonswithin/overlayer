//
//  ToastPresenterTests.swift
//  Overlayer
//
//  Created by Evgeny Blinov on 10.06.2026.
//

import Testing
@testable import Overlayer

@Suite struct ToastPresenterTests {
    @Test func showsUpToLimitAndQueuesTheRest() {
        let presenter = makeToastPresenter(maxVisible: 2)
        (0..<3).map { _ in makeToast(on: presenter) }.forEach { presenter.present($0) }
        #expect(presenter.visible.count == 2)
    }

    @Test func dismissPromotesQueuedToast() {
        let presenter = makeToastPresenter(maxVisible: 2)
        let toasts = (0..<3).map { _ in makeToast(on: presenter) }
        toasts.forEach { presenter.present($0) }
        presenter.dismiss(id: toasts[0].id)
        #expect(presenter.visible.map(\.id) == [toasts[1].id, toasts[2].id])
    }

    @Test func dismissAllClearsVisibleAndQueue() {
        let presenter = makeToastPresenter(maxVisible: 2)
        (0..<4).map { _ in makeToast(on: presenter) }.forEach { presenter.present($0) }
        presenter.dismissAll()
        #expect(presenter.visible.isEmpty)
        presenter.containerConfiguration.maxVisibleCount = 4
        #expect(presenter.visible.isEmpty, "the queue was cleared too")
    }

    @Test func pauseAndResumeToggleContextState() {
        let presenter = makeToastPresenter(maxVisible: 3)
        let toast = makeToast(on: presenter)
        presenter.present(toast)
        presenter.pause(id: toast.id)
        #expect(toast.context.isPaused)
        presenter.resume(id: toast.id)
        #expect(!toast.context.isPaused)
    }

    @Test func raisingLimitPromotesQueuedToasts() {
        let presenter = makeToastPresenter(maxVisible: 1)
        let toasts = (0..<3).map { _ in makeToast(on: presenter) }
        toasts.forEach { presenter.present($0) }
        #expect(presenter.visible.map(\.id) == [toasts[0].id])
        presenter.containerConfiguration.maxVisibleCount = 3
        #expect(presenter.visible.map(\.id) == toasts.map(\.id))
    }

    @Test func dismissQueuedToastRemovesItFromQueue() {
        let presenter = makeToastPresenter(maxVisible: 1)
        let toasts = (0..<3).map { _ in makeToast(on: presenter) }
        toasts.forEach { presenter.present($0) }
        presenter.dismiss(id: toasts[1].id)
        presenter.dismiss(id: toasts[0].id)
        #expect(presenter.visible.map(\.id) == [toasts[2].id])
    }

    @Test func visibleChangesNotify() {
        let presenter = makeToastPresenter(maxVisible: 1)
        var changes = 0
        presenter.onChange = { changes += 1 }
        let toasts = (0..<2).map { _ in makeToast(on: presenter) }
        toasts.forEach { presenter.present($0) }
        #expect(changes == 1, "a queued toast does not change the visible set")
        presenter.dismiss(id: toasts[0].id)
        #expect(changes == 3, "removal plus promotion of the queued toast")
    }

    @Test(.timeLimit(.minutes(1))) func dismissAllReportsSettled() async {
        let presenter = makeToastPresenter(maxVisible: 2)
        presenter.present(makeToast(on: presenter))
        await awaitCallback { done in
            presenter.onSettled = { if presenter.visible.isEmpty { done() } }
            presenter.dismissAll()
        }
        #expect(presenter.visible.isEmpty)
    }
}
