//
//  ConcurrencyTests.swift
//  Overlayer
//
//  Created by Evgeny Blinov on 11.11.2026.
//

import Foundation
import Testing
@testable import Overlayer
@testable import OverlayerDefaults

// Models are plain data: they must be creatable off the main actor (services, background tasks) and passable to it.
@Suite struct ConcurrencyTests {
    // A client module with MainActor default isolation declares its models `nonisolated` to use them off the main actor.
    nonisolated private struct ClientToast: ToastModel {
        let text: String
        var accessibilityAnnouncement: String? { text }
    }

    @Test nonisolated func modelsAreCreatableOffTheMainActor() {
        let toasts: [any ToastModel] = [
            SuccessToastModel(message: "a"),
            ErrorToastModel(title: "t", message: "b"),
            InfoToastModel(message: "c"),
            WarningToastModel(message: "d"),
            ClientToast(text: "e")
        ]
        #expect(toasts.compactMap(\.accessibilityAnnouncement) == ["a", "t. b", "c", "d", "e"])
        #expect(SpinnerLoadingModel(message: "s").accessibilityAnnouncement == "s")
    }

    @Test func bundledModelsCrossActors() async {
        let model = await Task.detached { SuccessToastModel(message: "from background") }.value
        #expect(model.message == "from background")
    }

    @Test(.timeLimit(.minutes(1))) func progressReportsFromBackground() async {
        let progress = LoadingProgress(message: "start")
        await Task.detached { progress.report(fraction: 0.5, message: "half") }.value
        await awaitCallback { done in
            Task {
                while progress.fraction != 0.5 { await Task.yield() }
                done()
            }
        }
        #expect(progress.fraction == 0.5)
        #expect(progress.message == "half")
    }

    @Test(.timeLimit(.minutes(1))) func reportWithoutMessageKeepsTheCurrentOne() async {
        let progress = LoadingProgress(message: "keep")
        progress.report(fraction: 1)
        await awaitCallback { done in
            Task {
                while progress.fraction != 1 { await Task.yield() }
                done()
            }
        }
        #expect(progress.message == "keep")
    }
}
