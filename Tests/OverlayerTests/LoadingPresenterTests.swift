//
//  LoadingPresenterTests.swift
//  Overlayer
//
//  Created by Evgeny Blinov on 10.06.2026.
//

import Testing
@testable import Overlayer

@Suite struct LoadingPresenterTests {
    @Test func topReflectsMostRecent() {
        let presenter = LoadingPresenter()
        let first = makeLoading(on: presenter)
        let second = makeLoading(on: presenter)
        presenter.present(first)
        presenter.present(second)
        #expect(presenter.stack.count == 2)
        #expect(presenter.top?.id == second.id)
    }

    @Test func hideRevealsPrevious() {
        let presenter = LoadingPresenter()
        let first = makeLoading(on: presenter)
        let second = makeLoading(on: presenter)
        presenter.present(first)
        presenter.present(second)
        presenter.hide(id: second.id)
        #expect(presenter.top?.id == first.id)
    }

    @Test func hideAllClearsStack() {
        let presenter = LoadingPresenter()
        presenter.present(makeLoading(on: presenter))
        presenter.present(makeLoading(on: presenter))
        presenter.hideAll()
        #expect(presenter.stack.isEmpty)
    }

    // Regression: a loading view dismissing itself (e.g. a Cancel button) must notify the window manager, otherwise the blocking window stays up over an empty stack.
    @Test func contextDismissRemovesAndNotifies() {
        let presenter = LoadingPresenter()
        var changes = 0
        presenter.onChange = { changes += 1 }
        let loading = makeLoading(on: presenter)
        presenter.present(loading)
        #expect(changes == 1)
        loading.context.dismiss()
        #expect(presenter.stack.isEmpty)
        #expect(changes == 2)
    }

    @Test func hideUnknownIdDoesNotNotify() {
        let presenter = LoadingPresenter()
        var changes = 0
        presenter.onChange = { changes += 1 }
        presenter.hide(id: LoadingID())
        #expect(changes == 0)
    }

    // The window manager hides the loading window only on this signal, so it must arrive after a removal.
    @Test(.timeLimit(.minutes(1))) func hideReportsSettled() async {
        let presenter = LoadingPresenter()
        let loading = makeLoading(on: presenter)
        presenter.present(loading)
        await awaitCallback { done in
            presenter.onSettled = { if presenter.stack.isEmpty { done() } }
            presenter.hide(id: loading.id)
        }
        #expect(presenter.stack.isEmpty)
    }

    // Regression: with overlapping changes, an earlier animation settling used to hide the window while a later one was still running.
    @Test func onlyTheLatestChangeReportsSettling() {
        let presenter = LoadingPresenter()
        let animations = ManualAnimations()
        presenter.performAnimation = animations.performer
        var settled = 0
        presenter.onSettled = { settled += 1 }
        let first = makeLoading(on: presenter)
        presenter.present(first)
        presenter.hide(id: first.id)
        presenter.present(makeLoading(on: presenter))
        animations.settle(1)
        #expect(settled == 0, "the hide animation finished, but a newer show is still running")
        animations.settle(2)
        #expect(settled == 1)
    }
}
