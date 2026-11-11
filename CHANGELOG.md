# Changelog

## Unreleased

### Changed

- The package builds with Swift 6.2 (Xcode 26) and newer; it no longer requires Swift 6.4.

## 2.0.1

### Added

- `ToastContainerConfiguration.maxWidth` (500 pt by default) keeps toasts from spanning wide screens.
- `ToastConfiguration.voiceOverMinimumLifetime`: while VoiceOver is running, short toasts stay at least 10 s.
- `LoadingProgress.report(fraction:message:)` updates progress from any thread.
- `ToastModel` and `LoadingModel` are `nonisolated`; the ready-made models are `nonisolated` and `Sendable`.
- CI workflow on GitHub Actions.

### Fixed

- The first toast and loader animate in instead of appearing at once.
- `.seconds(.infinity)` and very long lifetimes no longer crash; they behave like `.sticky`. Zero or negative lifetimes hide at once and log a warning.
- The last loader fades out instead of disappearing.
- A cancelled drag no longer leaves a toast paused forever; the swipe gesture is attached only when swipe-to-dismiss is on.
- `maxVisibleCount` below 1 is raised to 1 instead of queueing every toast.
- Overlay windows hide only after the latest animation.

## 2.0.0

### Breaking

- **Swift 6.4 toolchain required** to build the package (Swift 6 language mode, approachable concurrency). Apps still target iOS 16+.
- **Ready-made views moved to the `OverlayerDefaults` product.** `SuccessToastModel`, `ErrorToastModel`, `InfoToastModel`, `WarningToastModel`, `SpinnerLoadingModel`, `ProgressLoadingModel`, `LoadingProgress` and their views now live there. Add the product to your target and `import OverlayerDefaults`.
- **Registration renamed:** `Overlayer.registerExampleToasts()` → `registerDefaultToasts()`, `registerExampleLoading()` → `registerDefaultLoading()`. The old names remain as deprecated aliases.
- **`ToastContext.progress` is computed on read** instead of being `@Published` every frame. Read it inside `TimelineView(.animation(paused: context.isPaused))` to animate a custom bar, or use `ToastProgressBar`.

### Added

- VoiceOver: `accessibilityAnnouncement` on `ToastModel` and `LoadingModel`; Dismiss / Pause / Resume actions and the escape gesture on toasts; a blocking loader is modal for VoiceOver.
- Reduce Motion: toasts fade instead of sliding.
- Localized built-in strings (English, Russian).
- Configuration and id types are `nonisolated` and `Sendable`.
- Status bar, home indicator and orientation follow the app while an overlay is up.
- Overlay windows follow the scene when theirs is disconnected or backgrounded.
- Showing a model without a registered view is logged (`Overlayer` subsystem) in release builds.

### Fixed

- A loading view dismissing itself (e.g. Cancel) no longer leaves the screen blocked.
- Overlay windows are hidden when empty and only after their dismissal animation.
- A blocking loader ends text editing, since the keyboard sits above it.
- Raising `maxVisibleCount` shows queued toasts immediately.
- Toast lifetimes run on a monotonic clock with one task per toast instead of a 60 Hz tick.

## 1.0.0

- Initial release.
