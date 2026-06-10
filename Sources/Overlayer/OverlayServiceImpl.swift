//
//  OverlayServiceImpl.swift
//  Overlayer
//
//  Created by Evgeny Blinov on 10.06.2026.
//

import SwiftUI

/// Single implementation behind `OverlayService`. Holds the registries, presenters, and the shared window manager. Configure it through the `Overlayer` facade; inject it (as `OverlayService` or a narrower protocol) for runtime calls.
@MainActor public final class OverlayServiceImpl: OverlayService {
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
        let id = ToastID()
        let context = ToastContext(id: id, configuration: configuration, presenter: toastPresenter)
        guard let content = toastRegistry.makeView(for: model, context: context) else {
            assertionFailure("Overlayer: no toast view registered for \(type(of: model)). Call Overlayer.registerToast(_:content:) before showing it.")
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
            assertionFailure("Overlayer: no loading view registered for \(type(of: model)). Call Overlayer.registerLoading(_:content:) before showing it.")
            return id
        }
        loadingPresenter.present(ActiveLoading(id: id, model: model, configuration: configuration, context: context, content: content))
        windowManager.showLoading()
        return id
    }

    public func hideLoading(_ id: LoadingID) {
        loadingPresenter.hide(id: id)
        windowManager.syncLoading()
    }

    public func hideAllLoading() {
        loadingPresenter.hideAll()
        windowManager.syncLoading()
    }
}
