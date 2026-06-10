//
//  Overlayer.swift
//  Overlayer
//
//  Created by Evgeny Blinov on 10.06.2026.
//

import SwiftUI

/// Composition-root facade for Overlayer. Register your views and set global configuration here (once, at startup); inject `OverlayService` (or a narrower protocol) for runtime `show` / `showLoading` calls.
@MainActor public enum Overlayer {
    /// The shared service, ready to inject into a DI container or call directly.
    public static var service: any OverlayService { OverlayServiceImpl.shared }

    /// Stack-wide configuration shared by all toast containers.
    public static var toastContainerConfiguration: ToastContainerConfiguration {
        get { OverlayServiceImpl.shared.toastContainerConfiguration }
        set { OverlayServiceImpl.shared.toastContainerConfiguration = newValue }
    }

    /// Per-toast configuration used when `show` is called without one.
    public static var defaultToastConfiguration: ToastConfiguration {
        get { OverlayServiceImpl.shared.defaultToastConfiguration }
        set { OverlayServiceImpl.shared.defaultToastConfiguration = newValue }
    }

    /// Configuration used when `showLoading` is called without one.
    public static var loadingConfiguration: LoadingConfiguration {
        get { OverlayServiceImpl.shared.defaultLoadingConfiguration }
        set { OverlayServiceImpl.shared.defaultLoadingConfiguration = newValue }
    }

    /// Bind a toast model type to the SwiftUI view that renders it. View and model stay decoupled: add or remove types freely without touching any enum.
    public static func registerToast<Model: ToastModel, Content: View>(
        _ type: Model.Type,
        @ViewBuilder content: @escaping (Model, ToastContext) -> Content
    ) {
        OverlayServiceImpl.shared.registerToast(type, content: content)
    }

    /// Bind a loading model type to the SwiftUI view that renders it.
    public static func registerLoading<Model: LoadingModel, Content: View>(
        _ type: Model.Type,
        @ViewBuilder content: @escaping (Model, LoadingContext) -> Content
    ) {
        OverlayServiceImpl.shared.registerLoading(type, content: content)
    }
}
