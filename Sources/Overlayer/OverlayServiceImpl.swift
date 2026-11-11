//
//  OverlayServiceImpl.swift
//  Overlayer
//
//  Created by Evgeny Blinov on 10.06.2026.
//

import os
import SwiftUI

/// Single implementation behind `OverlayService`. Holds the registries, presenters, and the shared window manager. Configure it through the `Overlayer` facade; inject it (as `OverlayService` or a narrower protocol) for runtime calls.
public final class OverlayServiceImpl: OverlayService {
    /// Shared singleton. `nonisolated` so it can be registered from a DI container's non-isolated factory closure; the instance is `Sendable` because it is fully main-actor isolated.
    public nonisolated static let shared = OverlayServiceImpl()

    var toastContainerConfiguration: ToastContainerConfiguration = .default {
        didSet { toastPresenter.containerConfiguration = toastContainerConfiguration }
    }
    var defaultToastConfiguration: ToastConfiguration = .default
    var defaultLoadingConfiguration: LoadingConfiguration = .default

    private lazy var toastRegistry = OverlayRegistry<ToastContext>()
    private lazy var loadingRegistry = OverlayRegistry<LoadingContext>()
    private lazy var toastPresenter = ToastPresenter()
    private lazy var loadingPresenter = LoadingPresenter()
    private lazy var windowManager = OverlayWindowManager(toastPresenter: toastPresenter, loadingPresenter: loadingPresenter)

    nonisolated init() {}

    func registerToast<Model: ToastModel, Content: View>(
        _ type: Model.Type,
        @ViewBuilder content: @escaping (Model, ToastContext) -> Content
    ) {
        toastRegistry.register(type) { model, context in AnyView(content(model, context)) }
    }

    func registerLoading<Model: LoadingModel, Content: View>(
        _ type: Model.Type,
        @ViewBuilder content: @escaping (Model, LoadingContext) -> Content
    ) {
        loadingRegistry.register(type) { model, context in AnyView(content(model, context)) }
    }

    @discardableResult public func show<Model: ToastModel>(_ model: Model, configuration: ToastConfiguration?) -> ToastID {
        let configuration = configuration ?? defaultToastConfiguration
        if configuration.lifetime.isNonPositive {
            Self.logger.warning("Toast \(String(reflecting: Model.self), privacy: .public) has a non-positive lifetime and hides immediately.")
        }
        let id = ToastID()
        let context = ToastContext(id: id, configuration: configuration, presenter: toastPresenter)
        guard let content = toastRegistry.makeView(for: model, context: context) else {
            reportUnregistered(model, kind: "toast", register: "Overlayer.registerToast(_:content:)")
            return id
        }
        windowManager.activateToasts()
        toastPresenter.present(ActiveToast(id: id, model: model, configuration: configuration, context: context, content: content))
        return id
    }

    public func dismiss(_ id: ToastID) {
        toastPresenter.dismiss(id: id)
    }

    public func dismissAll() {
        toastPresenter.dismissAll()
    }

    @discardableResult public func showLoading<Model: LoadingModel>(_ model: Model, configuration: LoadingConfiguration?) -> LoadingID {
        let configuration = configuration ?? defaultLoadingConfiguration
        let id = LoadingID()
        let context = LoadingContext(id: id, presenter: loadingPresenter)
        guard let content = loadingRegistry.makeView(for: model, context: context) else {
            reportUnregistered(model, kind: "loading", register: "Overlayer.registerLoading(_:content:)")
            return id
        }
        // Prepare the window first, so the overlay is inserted into an already rendered host and its appear animation plays.
        windowManager.showLoading()
        loadingPresenter.present(ActiveLoading(id: id, model: model, configuration: configuration, context: context, content: content))
        return id
    }

    public func hideLoading(_ id: LoadingID) {
        loadingPresenter.hide(id: id)
    }

    public func hideAllLoading() {
        loadingPresenter.hideAll()
    }

    // Nothing is shown for a model without a registered view (the returned id is inert). Release builds log it, debug builds also stop at an assertion so the missing registration is caught early.
    private func reportUnregistered(_ model: Any, kind: String, register: String) {
        let message = "No \(kind) view registered for \(String(reflecting: type(of: model))). Views are looked up by the model's exact type; call \(register) before showing it."
        Self.logger.error("\(message, privacy: .public)")
        assertionFailure("Overlayer: \(message)")
    }

    private static let logger = Logger(subsystem: "Overlayer", category: "registry")
}
