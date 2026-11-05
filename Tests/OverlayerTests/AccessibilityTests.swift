//
//  AccessibilityTests.swift
//  Overlayer
//
//  Created by Evgeny Blinov on 05.11.2026.
//

import Foundation
import SwiftUI
import Testing
@testable import Overlayer

@Suite struct AccessibilityTests {
    private struct Announced: ToastModel {
        let text: String
        var accessibilityAnnouncement: String? { text }
    }

    private func makeAnnouncedToast(_ text: String, on presenter: ToastPresenter) -> ActiveToast {
        let configuration = ToastConfiguration(lifetime: .sticky)
        let id = ToastID()
        let context = ToastContext(id: id, configuration: configuration, presenter: presenter)
        return ActiveToast(id: id, model: Announced(text: text), configuration: configuration, context: context, content: AnyView(EmptyView()))
    }

    @Test func toastIsAnnouncedWhenItBecomesVisible() {
        let presenter = makeToastPresenter(maxVisible: 1)
        var spoken: [String?] = []
        presenter.announce = { spoken.append($0) }
        let first = makeAnnouncedToast("first", on: presenter)
        presenter.present(first)
        presenter.present(makeAnnouncedToast("queued", on: presenter))
        #expect(spoken == ["first"], "a queued toast is not announced yet")
        presenter.dismiss(id: first.id)
        #expect(spoken == ["first", "queued"])
    }

    @Test func modelsAnnounceNothingByDefault() {
        #expect(DummyToast().accessibilityAnnouncement == nil)
        #expect(DummyLoading().accessibilityAnnouncement == nil)
    }

    @Test func exampleToastsAnnounceTitleAndMessage() {
        #expect(ErrorToastModel(title: "Upload failed", message: "Check your connection").accessibilityAnnouncement == "Upload failed. Check your connection")
        #expect(SuccessToastModel(message: "Saved").accessibilityAnnouncement == "Saved")
    }

    @Test func exampleLoadersFallBackToLocalizedLoading() {
        #expect(SpinnerLoadingModel(message: "Syncing…").accessibilityAnnouncement == "Syncing…")
        #expect(SpinnerLoadingModel().accessibilityAnnouncement == OverlayAccessibility.localized("Loading"))
    }

    @Test(arguments: [("Close", "Закрыть"), ("Dismiss", "Скрыть"), ("Pause", "Приостановить"), ("Resume", "Продолжить"), ("Loading", "Загрузка")])
    func russianTranslationsShip(key: String, expected: String) throws {
        let path = try #require(Bundle.module.path(forResource: "ru", ofType: "lproj"), "ru.lproj is missing from the package bundle")
        let russian = try #require(Bundle(path: path))
        #expect(russian.localizedString(forKey: key, value: nil, table: nil) == expected)
    }
}
