//
//  ToastContext.swift
//  Overlayer
//
//  Created by Evgeny Blinov on 10.06.2026.
//

import Combine
import SwiftUI

/// Live handle handed to every toast view. It exposes imperative controls (`dismiss`, `pause`, `resume`) and observable state (`progress`, `isPaused`) so a custom view can render its own chrome, while the bundled `ToastCard` consumes the very same context.
@MainActor public final class ToastContext: ObservableObject {
    /// Identifier of the presentation this context drives.
    public let id: ToastID
    /// Whether the default chrome should render a close button.
    public let showsCloseButton: Bool
    /// Whether the default chrome should render a progress bar.
    public let showsProgressBar: Bool
    /// `true` when the toast auto-dismisses (non-sticky); progress is only meaningful then.
    public let isProgressive: Bool
    /// Remaining fraction of the lifetime, draining from 1 to 0.
    @Published public internal(set) var progress: Double = 1
    /// `true` while the lifetime is paused (e.g. held under a finger).
    @Published public internal(set) var isPaused: Bool = false
    private weak var presenter: ToastPresenter?

    init(
        id: ToastID,
        configuration: ToastConfiguration,
        presenter: ToastPresenter
    ) {
        self.id = id
        self.showsCloseButton = configuration.showsCloseButton
        self.showsProgressBar = configuration.showsProgressBar
        self.isProgressive = configuration.lifetime.duration != nil
        self.presenter = presenter
    }

    /// Dismiss this toast immediately (animated).
    public func dismiss() { presenter?.dismiss(id: id) }

    /// Pause the lifetime countdown.
    public func pause() { presenter?.pause(id: id) }

    /// Resume the lifetime countdown.
    public func resume() { presenter?.resume(id: id) }
}
