# Known issues

Code review of 2.0.0 (`b208574`). Each task lists the problem and the fix; the roadmap is at the end.

| # | Task | Labels | Status |
|---|---|---|---|
| 1 | [Crash on infinite or huge toast lifetime](#1-crash-on-infinite-or-huge-toast-lifetime) | bug, priority: high | Fixed |
| 2 | [Last loader disappears without animation](#2-last-loader-disappears-without-animation) | bug, priority: high | Fixed; fade-out checked on a simulator |
| 3 | [Toast can stay paused forever after a cancelled drag](#3-toast-can-stay-paused-forever-after-a-cancelled-drag) | bug, priority: high | Fixed; spring-back, swipe-to-dismiss and resume after a drag checked on a simulator |
| 4 | [maxVisibleCount ≤ 0 silently hides all toasts](#4-maxvisiblecount--0-silently-hides-all-toasts) | bug | Fixed |
| 5 | [Bundled models and LoadingProgress can't be used off the main actor](#5-bundled-models-and-loadingprogress-cant-be-used-off-the-main-actor) | bug, api | Fixed |
| 6 | [iPad multi-window: overlay appears in an arbitrary scene](#6-ipad-multi-window-overlay-appears-in-an-arbitrary-scene) | bug, enhancement | Documented in README; per-scene overlays are on the roadmap |
| 7 | [Toasts stretch to the full screen width](#7-toasts-stretch-to-the-full-screen-width) | enhancement | Fixed; checked in landscape on a simulator |
| 8 | [Overlay window can hide too early; first show has no appear animation](#8-overlay-window-can-hide-too-early-first-show-has-no-appear-animation) | bug | Fixed; first loader and toast animate in (checked on a simulator); iOS 16 delay documented |
| 9 | [VoiceOver: toast disappears before it can be reached](#9-voiceover-toast-disappears-before-it-can-be-reached) | accessibility | Lifetime fixed; check the actions with VoiceOver on a device |
| 10 | [Tests and CI](#10-tests-and-ci) | infrastructure | Timing tests and CI done; window and gesture tests open |
| 11 | [Document blocking loader limitations](#11-document-blocking-loader-limitations) | documentation | Documented in README |
| 12 | [Minor cleanups](#12-minor-cleanups) | chore | `.gitignore`, doc comments and toolchain support (tools 6.2) done; model unification open |

## 1. Crash on infinite or huge toast lifetime

*bug, priority: high* · **Status:** Fixed

### Problem

[`ToastPresenter.startLifetime`](https://github.com/thedemonswithin/overlayer/blob/b208574/Sources/Overlayer/Toast/ToastPresenter.swift#L102) converts the remaining time with `UInt64(remaining * 1_000_000_000)`. For `.seconds(.infinity)` or any value above ~1.8·10¹⁰ s this is a runtime trap, so the app crashes. `.seconds(.infinity)` is a natural way to say "never hide".

Negative values and NaN don't crash, but the toast disappears instantly with no warning.

### Fix

- Normalize the duration in one place: non-finite or too large → treat as `.sticky`; ≤ 0 → dismiss immediately and log.
- Tests for `.infinity`, `.nan`, a negative value and `greatestFiniteMagnitude`.

## 2. Last loader disappears without animation

*bug, priority: high* · **Status:** Fixed; fade-out checked on a simulator

### Problem

[`LoadingHostView`](https://github.com/thedemonswithin/overlayer/blob/b208574/Sources/Overlayer/Loading/LoadingHostView.swift#L30) applies `.animation(presenter.top?.configuration.animation, value: presenter.stack.count)`.

When the stack empties, `top` is `nil`, so the modifier gets `.animation(nil, value:)`, which disables animation for that change and overrides the `withAnimation` in `LoadingPresenter`. The content vanishes instantly while the window still waits for the "animation" to finish. When nested loaders swap, the new top's animation is used instead of the removed one's.

Found by reading the code; not yet confirmed on a device.

### Fix

- Remove the modifier; `LoadingPresenter` already wraps every change in `withAnimation`.
- Check on a device: fade-out of the last loader and the A → B swap.

## 3. Toast can stay paused forever after a cancelled drag

*bug, priority: high* · **Status:** Fixed; spring-back, swipe-to-dismiss and resume after a drag checked on a simulator

### Problem

In [`ToastItemView`](https://github.com/thedemonswithin/overlayer/blob/b208574/Sources/Overlayer/Toast/Views/ToastItemView.swift#L38) `isDragging` is set in `onChanged` and cleared only in `onEnded`. SwiftUI doesn't call `onEnded` when a gesture is cancelled (system gesture, incoming call, another recognizer takes over). `isDragging` then stays `true`, [`syncPause`](https://github.com/thedemonswithin/overlayer/blob/b208574/Sources/Overlayer/Toast/Views/ToastItemView.swift#L75) keeps the toast paused, and it never auto-dismisses.

This also affects toasts with swipe disabled: the `DragGesture` is always attached.

Found by reading the code; not reproduced yet.

### Fix

- Track the drag with `@GestureState`, which also resets on cancellation.
- Don't attach the `DragGesture` when `isSwipeToDismissEnabled == false`.

## 4. maxVisibleCount ≤ 0 silently hides all toasts

*bug* · **Status:** Fixed

### Problem

With `maxVisibleCount` of 0 or less, the check `visible.count < maxVisibleCount` in [`ToastPresenter.present`](https://github.com/thedemonswithin/overlayer/blob/b208574/Sources/Overlayer/Toast/ToastPresenter.swift#L32) never passes. Toasts pile up in the queue, nothing is shown, and there is no error.

### Fix

- Clamp the value to at least 1 in [`ToastContainerConfiguration`](https://github.com/thedemonswithin/overlayer/blob/b208574/Sources/Overlayer/Toast/ToastContainerConfiguration.swift#L15) (init or `didSet`).
- Add a test.

## 5. Bundled models and LoadingProgress can't be used off the main actor

*bug, api* · **Status:** Fixed

### Problem

Because of `defaultIsolation(MainActor)`, a Swift 6 client gets compile errors (checked with a probe package):

- `SuccessToastModel(message:)` and `SpinnerLoadingModel(message:)` can't be created in nonisolated code (a service, a background task).
- `progress.fraction = …` can't be set from a background upload callback — the main use case for [`LoadingProgress`](https://github.com/thedemonswithin/overlayer/blob/b208574/Sources/OverlayerDefaults/DefaultLoading.swift#L45).
- `accessibilityAnnouncement` on a custom model is main-actor isolated ([`ToastModel`](https://github.com/thedemonswithin/overlayer/blob/b208574/Sources/Overlayer/Toast/ToastModel.swift#L11), [`LoadingModel`](https://github.com/thedemonswithin/overlayer/blob/b208574/Sources/Overlayer/Loading/LoadingModel.swift#L11)).

Configurations and ids are already `nonisolated`, so data types behave inconsistently.

### Fix

- Mark the bundled models `nonisolated` + `Sendable`; make the model protocols `nonisolated`.
- Give `LoadingProgress` a thread-safe way to update (a nonisolated method that hops to main), or document the restriction.
- Add probe tests that create models off the main actor.

## 6. iPad multi-window: overlay appears in an arbitrary scene

*bug, enhancement* · **Status:** Documented in README; per-scene overlays are on the roadmap

### Problem

The window is placed in the first `foregroundActive` scene ([`OverlayScene`](https://github.com/thedemonswithin/overlayer/blob/b208574/Sources/Overlayer/Overlay/OverlayScene.swift#L15), [`OverlayWindowSlot.prepare`](https://github.com/thedemonswithin/overlayer/blob/b208574/Sources/Overlayer/Overlay/OverlayWindowSlot.swift#L23)) and stays there while that scene is visible.

- A toast triggered from window B shows in window A.
- A blocking loader blocks the wrong window and leaves the right one interactive.
- The API has no way to choose a scene.

### Fix

- At minimum, document the limitation in the README.
- Full fix: one set of overlay windows per scene and an optional scene parameter in `show` / `showLoading` (see the roadmap issue).

## 7. Toasts stretch to the full screen width

*enhancement* · **Status:** Fixed; checked in landscape on a simulator

### Problem

[`ToastHostView`](https://github.com/thedemonswithin/overlayer/blob/b208574/Sources/Overlayer/Toast/Views/ToastHostView.swift#L31) gives every toast `.frame(maxWidth: .infinity)`. On iPad and in landscape a toast spans the whole screen; the configuration has no width limit.

### Fix

Add `maxWidth` to `ToastContainerConfiguration` with a sensible default (around 500 pt) and center the toasts.

## 8. Overlay window can hide too early; first show has no appear animation

*bug* · **Status:** Fixed; first loader and toast animate in (checked on a simulator); iOS 16 delay documented

### Problem

- The "animation settled" signal isn't tied to a specific change ([`OverlayWindowManager`](https://github.com/thedemonswithin/overlayer/blob/b208574/Sources/Overlayer/Overlay/OverlayWindowManager.swift#L64), [lines 104–107](https://github.com/thedemonswithin/overlayer/blob/b208574/Sources/Overlayer/Overlay/OverlayWindowManager.swift#L104)). With a quick hide → show → hide, the first animation's completion hides the window while the last one is still running.
- On iOS 16 a fixed 0.8 s delay replaces the completion ([`OverlayAnimation`](https://github.com/thedemonswithin/overlayer/blob/b208574/Sources/Overlayer/Overlay/OverlayAnimation.swift#L13)); longer animations get cut.
- On the very first `showLoading` the item enters the stack before the window exists ([`OverlayServiceImpl`](https://github.com/thedemonswithin/overlayer/blob/b208574/Sources/Overlayer/OverlayServiceImpl.swift#L73)), so there's no appear animation.

### Fix

- Number the changes and hide the window only on the signal from the latest one.
- In `showLoading`, prepare the window first, then add the item.
- For iOS 16, derive the delay from the animation or document the limitation.

## 9. VoiceOver: toast disappears before it can be reached

*accessibility* · **Status:** Lifetime fixed; check the actions with VoiceOver on a device

### Problem

- The lifetime doesn't change when VoiceOver is on ([`ToastPresenter`](https://github.com/thedemonswithin/overlayer/blob/b208574/Sources/Overlayer/Toast/ToastPresenter.swift#L95)). In 4 seconds a user can't navigate to the toast to press a button inside it or trigger Pause.
- The Dismiss / Pause actions and escape are attached to the container (`children: .contain`, [`ToastItemView`](https://github.com/thedemonswithin/overlayer/blob/b208574/Sources/Overlayer/Toast/Views/ToastItemView.swift#L26)); it hasn't been checked on a device that VoiceOver actually offers them.

### Fix

- When `UIAccessibility.isVoiceOverRunning`, extend the lifetime or pause the toast while it has focus.
- Verify the actions on a real device.

## 10. Tests and CI

*infrastructure* · **Status:** Timing tests and CI done; window and gesture tests open

### Problem

- `OverlayWindowManager`, `OverlayWindowSlot` (install, waiting for a scene, relocation) and the `ToastItemView` gestures aren't covered.
- Three tests wait on real time (`.seconds(0.05)`, `Task.sleep`) and may flake on a busy machine.
- No CI: the repository has no `.github` folder.

### Fix

- Make the sleep an injectable dependency of the presenter.
- Add window tests.
- Set up GitHub Actions to build and run the tests.

## 11. Document blocking loader limitations

*documentation* · **Status:** Documented in README

### Problem

The README doesn't describe two cases:

- The loader window sits above the app window, so an alert or sheet the app presents while a blocking loader is up ends up under it and can't be used.
- If `hideLoading` is forgotten, the app stays blocked; there's no safety timeout.

### Fix

Describe both cases in the README.

## 12. Minor cleanups

*chore* · **Status:** `.gitignore`, doc comments and toolchain support (tools 6.2) done; model unification open

- `.serena/` isn't in `.gitignore`.
- Public `ToastCard`, `ToastCloseButton`, `ToastPosition`, `ToastLifetime` have no doc comments.
- The four bundled toast models and four views are identical apart from icon and color; they could become one model with a style.
- ~~`swift-tools-version: 6.4` excludes everyone on Xcode older than 27.~~ Lowered to 6.2, the minimum for `defaultIsolation`; going lower would need a separate manifest without MainActor default isolation.

## Roadmap

1. **Reliability (2.0.1):** task 1, task 2, task 3, task 4, task 8 — fixes without API changes.
2. **Off-main-actor API (2.1):** task 5. Plus a `withLoading { try await … }` wrapper that always hides the loader, and an optional timeout for the blocking loader.
3. **Layout and gestures (2.1):** `maxWidth` (task 7), horizontal swipe to dismiss, a visible-toast limit per position instead of a shared one.
4. **Queue control (2.2):** priorities, deduplication and replacement of identical toasts, a queue length limit, updating a shown toast or loader by id.
5. **SwiftUI interface (2.2):** a `.toast(item:)` modifier and the service in `Environment` as an alternative to the global `Overlayer.service`.
6. **Multi-window (3.0):** overlays per scene and scene selection in the API (task 6); check Mac Catalyst and visionOS.
7. **Accessibility:** task 9; pause the lifetime while the app is in the background (toasts currently expire there too).
8. **Infrastructure:** CI (task 10), DocC documentation, snapshot or UI tests for animations and gestures, support for toolchains older than 6.2.

