//
//  OverlayService.swift
//  Overlayer
//
//  Created by Evgeny Blinov on 10.06.2026.
//

import SwiftUI

/// Presents transient toasts. Inject this where a screen only needs to show toasts.
@MainActor public protocol ToastPresenting: AnyObject {
    @discardableResult func show<Model: ToastModel>(_ model: Model, configuration: ToastConfiguration?) -> ToastID
    func dismiss(_ id: ToastID)
    func dismissAll()
}

/// Presents the blocking loading overlay. Inject this where a screen only needs loading.
@MainActor public protocol LoadingPresenting: AnyObject {
    @discardableResult func showLoading<Model: LoadingModel>(_ model: Model, configuration: LoadingConfiguration?) -> LoadingID
    func hideLoading(_ id: LoadingID)
    func hideAllLoading()
}

/// The full overlay surface (toasts + loading). Register `OverlayServiceImpl.shared` in your DI container as this, or as one of the narrower protocols above.
@MainActor public protocol OverlayService: ToastPresenting, LoadingPresenting {}

public extension ToastPresenting {
    /// Show a toast using the configured default (`Overlayer.defaultToastConfiguration`).
    @discardableResult func show<Model: ToastModel>(_ model: Model) -> ToastID {
        show(model, configuration: nil)
    }
}

public extension LoadingPresenting {
    /// Show a loading overlay using the configured default (`Overlayer.loadingConfiguration`).
    @discardableResult func showLoading<Model: LoadingModel>(_ model: Model) -> LoadingID {
        showLoading(model, configuration: nil)
    }
}
