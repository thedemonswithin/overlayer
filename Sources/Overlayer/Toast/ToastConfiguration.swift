//
//  ToastConfiguration.swift
//  Overlayer
//
//  Created by Evgeny Blinov on 10.06.2026.
//

public import Foundation

/// Per-toast configuration — properties specific to a single toast, passed to `show` (or taken from `Overlayer.defaultToastConfiguration`). Stack-wide layout lives in `ToastContainerConfiguration`.
nonisolated public struct ToastConfiguration: Sendable {
    public static let `default` = ToastConfiguration()

    /// Edge this toast is anchored to. Toasts with different positions render in separate containers, so top and bottom toasts can be shown at the same time.
    public var position: ToastPosition
    /// Auto-dismiss timing.
    public var lifetime: ToastLifetime
    /// Haptic played when the toast appears.
    public var haptic: ToastHapticFeedback
    /// Whether a swipe towards the anchored edge dismisses the toast.
    public var isSwipeToDismissEnabled: Bool
    /// Whether a tap toggles pause: the first tap freezes the toast so it can be read, a second tap resumes the countdown to auto-dismiss.
    public var isTapToPauseEnabled: Bool
    /// Whether pressing and holding the toast pauses it while the finger is down, resuming on release.
    public var isHoldToPauseEnabled: Bool
    /// Whether the bundled `ToastCard` chrome shows a close button.
    public var showsCloseButton: Bool
    /// Whether the bundled `ToastCard` chrome shows the bottom progress bar.
    public var showsProgressBar: Bool
    /// Shortest countdown while VoiceOver is running, in seconds. A VoiceOver user needs time to reach the toast before it hides, so a shorter lifetime is extended to this value; sticky and longer lifetimes are unchanged.
    public var voiceOverMinimumLifetime: TimeInterval

    public init(
        position: ToastPosition = .bottom,
        lifetime: ToastLifetime = .default,
        haptic: ToastHapticFeedback = .none,
        isSwipeToDismissEnabled: Bool = false,
        isTapToPauseEnabled: Bool = false,
        isHoldToPauseEnabled: Bool = true,
        showsCloseButton: Bool = true,
        showsProgressBar: Bool = true,
        voiceOverMinimumLifetime: TimeInterval = 10
    ) {
        self.position = position
        self.lifetime = lifetime
        self.haptic = haptic
        self.isSwipeToDismissEnabled = isSwipeToDismissEnabled
        self.isTapToPauseEnabled = isTapToPauseEnabled
        self.isHoldToPauseEnabled = isHoldToPauseEnabled
        self.showsCloseButton = showsCloseButton
        self.showsProgressBar = showsProgressBar
        self.voiceOverMinimumLifetime = voiceOverMinimumLifetime
    }
}
