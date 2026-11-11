//
//  ToastPresenterTests.swift
//  Overlayer
//
//  Created by Evgeny Blinov on 10.06.2026.
//

import Foundation
import SwiftUI
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

    @Test(.timeLimit(.minutes(1))) func autoDismissesAfterLifetime() async {
        let presenter = makeToastPresenter(maxVisible: 3)
        let toast = makeToast(on: presenter, lifetime: .seconds(0.05))
        await awaitCallback { done in
            presenter.onChange = { if presenter.visible.isEmpty { done() } }
            presenter.present(toast)
        }
        #expect(presenter.visible.isEmpty)
    }

    @Test(.timeLimit(.minutes(1))) func pausedToastDoesNotExpireUntilResumed() async throws {
        let presenter = makeToastPresenter(maxVisible: 3)
        let toast = makeToast(on: presenter, lifetime: .seconds(0.05))
        presenter.present(toast)
        presenter.pause(id: toast.id)
        try await Task.sleep(nanoseconds: 200_000_000)
        #expect(presenter.visible.map(\.id) == [toast.id], "a paused toast outlives its lifetime")
        await awaitCallback { done in
            presenter.onChange = { if presenter.visible.isEmpty { done() } }
            presenter.resume(id: toast.id)
        }
        #expect(presenter.visible.isEmpty)
    }

    @Test func queuedToastStartsItsLifetimeWhenShown() {
        let presenter = makeToastPresenter(maxVisible: 1)
        let first = makeToast(on: presenter)
        let queued = makeToast(on: presenter, lifetime: .seconds(4))
        presenter.present(first)
        presenter.present(queued)
        #expect(!queued.context.timer.isRunning)
        presenter.dismiss(id: first.id)
        #expect(queued.context.timer.isRunning)
    }

    @Test func pauseFreezesProgress() {
        var now: TimeInterval = 100
        let presenter = makeToastPresenter(maxVisible: 1)
        let configuration = ToastConfiguration(lifetime: .seconds(4))
        let id = ToastID()
        let context = ToastContext(id: id, configuration: configuration, presenter: presenter, clock: { now })
        presenter.present(ActiveToast(id: id, model: DummyToast(), configuration: configuration, context: context, content: AnyView(EmptyView())))
        now = 101
        #expect(context.progress == 0.75)
        presenter.pause(id: id)
        now = 150
        #expect(context.progress == 0.75)
        #expect(context.isPaused)
        presenter.dismiss(id: id)
    }

    // Regression: converting an infinite remaining time into a sleep duration used to trap.
    @Test(arguments: [TimeInterval.infinity, .greatestFiniteMagnitude, .nan])
    func unboundedLifetimeIsSticky(seconds: TimeInterval) {
        let presenter = makeToastPresenter(maxVisible: 1)
        let toast = makeToast(on: presenter, lifetime: .seconds(seconds))
        presenter.present(toast)
        #expect(presenter.visible.map(\.id) == [toast.id])
        #expect(!toast.context.isProgressive)
        #expect(toast.context.progress == 1)
        presenter.dismiss(id: toast.id)
    }

    @Test(.timeLimit(.minutes(1))) func negativeLifetimeHidesImmediately() async {
        let presenter = makeToastPresenter(maxVisible: 1)
        let toast = makeToast(on: presenter, lifetime: .seconds(-1))
        await awaitCallback { done in
            presenter.onChange = { if presenter.visible.isEmpty { done() } }
            presenter.present(toast)
        }
        #expect(presenter.visible.isEmpty)
    }

    // Regression: a zero limit used to queue every toast forever.
    @Test func zeroLimitStillShowsOneToast() {
        let presenter = makeToastPresenter(maxVisible: 0)
        let toast = makeToast(on: presenter)
        presenter.present(toast)
        #expect(presenter.visible.map(\.id) == [toast.id])
    }

    @Test func onlyTheLatestChangeReportsSettling() {
        let presenter = makeToastPresenter(maxVisible: 3)
        let animations = ManualAnimations()
        presenter.performAnimation = animations.performer
        var settled = 0
        presenter.onSettled = { settled += 1 }
        let toast = makeToast(on: presenter)
        presenter.present(toast)
        presenter.dismiss(id: toast.id)
        presenter.present(makeToast(on: presenter))
        animations.settle(0)
        animations.settle(1)
        #expect(settled == 0)
        animations.settle(2)
        #expect(settled == 1)
    }
}
