//
//  ToastContext.swift
//  Overlayer
//
//  Created by Evgeny Blinov on 10.06.2026.
//

public import Combine
import Foundation

/// Live handle handed to every toast view. It exposes imperative controls (`dismiss`, `pause`, `resume`) and state (`progress`, `isPaused`) so a custom view can render its own chrome, while the bundled `ToastCard` consumes the very same context.
public final class ToastContext: ObservableObject {
    /// Identifier of the presentation this context drives.
    public let id: ToastID
    /// Whether the default chrome should render a close button.
    public let showsCloseButton: Bool
    /// Whether the default chrome should render a progress bar.
    public let showsProgressBar: Bool
    /// `true` when the toast auto-dismisses (non-sticky); progress is only meaningful then.
    public let isProgressive: Bool
    /// `true` while the lifetime is paused (e.g. held under a finger). Published, so views update when it flips.
    @Published public internal(set) var isPaused: Bool = false

    /// Remaining fraction of the lifetime, draining from 1 to 0 (always 1 for a sticky toast).
    ///
    /// Computed on read rather than published on every frame: to animate it, read it inside a `TimelineView(.animation(paused: context.isPaused))`, as `ToastProgressBar` does.
    public var progress: Double { timer.progress(at: clock()) }

    var timer: ToastTimer
    let clock: () -> TimeInterval
    private weak var presenter: ToastPresenter?

    init(
        id: ToastID,
        configuration: ToastConfiguration,
        presenter: ToastPresenter,
        clock: @escaping () -> TimeInterval = OverlayClock.now
    ) {
        self.id = id
        self.showsCloseButton = configuration.showsCloseButton
        self.showsProgressBar = configuration.showsProgressBar
        self.isProgressive = configuration.lifetime.duration != nil
        self.timer = ToastTimer(total: configuration.lifetime.duration)
        self.clock = clock
        self.presenter = presenter
    }

    /// Dismiss this toast immediately (animated).
    public func dismiss() { presenter?.dismiss(id: id) }

    /// Pause the lifetime countdown.
    public func pause() { presenter?.pause(id: id) }

    /// Resume the lifetime countdown.
    public func resume() { presenter?.resume(id: id) }
}
