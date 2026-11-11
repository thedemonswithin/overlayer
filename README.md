<p align="center">
  <img src="Assets/logo.png" alt="Overlayer" width="480">
</p>

# Overlayer

Toasts and loading overlays for SwiftUI and UIKit apps. They live in their own windows, so they show above any screen, sheet or alert, and you can call them from anywhere.

- **Toasts** never block the app: touches outside a toast go straight through.
- **Loading** blocks the screen until you hide it (or lets touches through, if you ask).
- Any model type can have its own view. Ready-made Success / Error / Info / Warning toasts and a spinner / progress loader are included.

iOS 16+, no dependencies.

## Installation

Swift Package Manager:

```swift
.package(url: "https://github.com/thedemonswithin/overlayer.git", from: "2.0.0")
```

Add `Overlayer` to your target, and `OverlayerDefaults` if you want the ready-made views. The package builds with Swift 6.2 or newer (Xcode 26+). Coming from 1.x? See [CHANGELOG.md](CHANGELOG.md).

## Quick start

Register views once at startup, then show overlays from anywhere:

```swift
import Overlayer
import OverlayerDefaults

@main
struct DemoApp: App {
    init() {
        Overlayer.registerDefaultToasts()
        Overlayer.registerDefaultLoading()
    }

    var body: some Scene {
        WindowGroup { ContentView() }
    }
}
```

```swift
Overlayer.service.show(SuccessToastModel(message: "Saved"))

let id = Overlayer.service.showLoading(SpinnerLoadingModel(message: "Loading…"))
Overlayer.service.hideLoading(id)
```

## Toasts

```swift
Overlayer.service.show(
    ErrorToastModel(title: "Upload failed", message: "Check your connection"),
    configuration: ToastConfiguration(position: .top, lifetime: .seconds(6))
)
```

- Top, center and bottom toasts can be on screen at the same time; extra toasts wait in a queue.
- A toast hides itself after its lifetime, or stays until closed with `.sticky` (an infinite `.seconds` value works the same).
- Users can close a toast with its button or a swipe, and pause it with a hold or a tap (swipe and tap are opt-in).
- `Overlayer.service.dismiss(id)` and `dismissAll()` close toasts from code.

### Your own toast

A toast is a plain model plus any SwiftUI view. `ToastCard` gives you the standard look with a close button and a progress bar:

```swift
struct DownloadToastModel: ToastModel {
    let fileName: String
    var accessibilityAnnouncement: String? { "Downloaded \(fileName)" }
}

Overlayer.registerToast(DownloadToastModel.self) { model, context in
    ToastCard(context: context, accent: .indigo) {
        HStack {
            Text("Downloaded \(model.fileName)")
            Button("Open") { context.dismiss() }
        }
    }
}
```

The `context` lets the view `dismiss()`, `pause()` and `resume()` its toast.

## Loading

Loading overlays stack, so nested loads work: the newest one is shown, and the screen stays blocked until the last one is hidden.

```swift
// Determinate progress you update as the work goes
let progress = LoadingProgress(message: "Uploading…")
let id = Overlayer.service.showLoading(ProgressLoadingModel(progress: progress))
progress.fraction = 0.4                  // on the main actor
progress.report(fraction: 0.6)           // from any thread, e.g. a URLSession delegate
Overlayer.service.hideLoading(id)

// Visual only: the screen stays interactive
Overlayer.service.showLoading(
    SpinnerLoadingModel(message: "Syncing…"),
    configuration: LoadingConfiguration(isBlocking: false, backgroundStyle: AnyShapeStyle(Color.clear))
)
```

Custom loaders register with `Overlayer.registerLoading(_:content:)`. Their `LoadingContext` can `dismiss()`, for example from a Cancel button.

## Configuration

Set defaults once; pass a configuration to a single `show` / `showLoading` to override them.

```swift
Overlayer.toastContainerConfiguration = ToastContainerConfiguration(maxVisibleCount: 4)
Overlayer.defaultToastConfiguration = ToastConfiguration(haptic: .notification(.success))
Overlayer.loadingConfiguration = LoadingConfiguration(backgroundStyle: AnyShapeStyle(.ultraThinMaterial))
```

| Type | Options |
|---|---|
| `ToastContainerConfiguration` | `maxVisibleCount`, `spacing`, `edgeInsets`, `maxWidth`, `animation` |
| `ToastConfiguration` | `position`, `lifetime`, `haptic`, `isSwipeToDismissEnabled`, `isTapToPauseEnabled`, `isHoldToPauseEnabled`, `showsCloseButton`, `showsProgressBar`, `voiceOverMinimumLifetime` |
| `LoadingConfiguration` | `isBlocking`, `backgroundStyle`, `ignoresSafeArea`, `animation` |

## Accessibility

- VoiceOver reads a toast when it appears, using the model's `accessibilityAnnouncement`. The ready-made models fill it in for you.
- Every toast has *Dismiss* and *Pause* / *Resume* actions, and the escape gesture closes it.
- While VoiceOver is running, a toast stays at least `voiceOverMinimumLifetime` (10 s) so the user can reach it.
- While a blocking loader is up, VoiceOver stays inside it.
- With Reduce Motion on, toasts fade instead of sliding.
- Built-in strings are in English and Russian.

## Good to know

- Call the service from the main actor. Models, configurations and ids can be created anywhere; the ready-made models are `Sendable`. If your module uses MainActor default isolation, declare your own models `nonisolated` to build them off the main actor.
- A model is shown only if a view is registered for its exact type. A missing registration stops at an assertion in debug and is logged in release.
- The status bar, home indicator and rotation follow your app while an overlay is visible.
- With dependency injection, register `OverlayServiceImpl.shared` and inject `OverlayService`, `ToastPresenting` or `LoadingPresenting`:

```swift
container.register { OverlayServiceImpl.shared as OverlayService }
```

## Limitations

- **Multiple windows on iPad.** Overlays appear in the foreground scene they were first shown in and stay there while it is visible, so a toast or loader triggered from another window may show in the wrong one.
- **Alerts under a blocking loader.** The loader sits above the app's window, so an alert or sheet the app presents while a blocking loader is up appears beneath it and can't be used. Hide the loader first.
- **Forgotten `hideLoading`.** A blocking loader stays until it is hidden; there is no timeout. Pair every `showLoading` with `hideLoading`, for example in a `defer`.
- **iOS 16 animations.** Without animation completion on iOS 16, an overlay window hides 0.8 s after its last change, so a custom animation longer than that is cut short.

## Example

`Example/` contains a demo app with every feature. Open `Example/OverlayerExample.xcodeproj` and run it.
