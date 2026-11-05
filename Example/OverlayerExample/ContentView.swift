//
//  ContentView.swift
//  OverlayerExample
//
//  Created by Evgeny Blinov on 10.06.2026.
//

import Overlayer
import SwiftUI

struct ContentView: View {
    @State private var position: ToastPosition = .bottom
    @State private var maxVisible = 3
    @State private var draft = ""

    private var overlay: any OverlayService { Overlayer.service }

    var body: some View {
        NavigationStack {
            Form {
                toastsSection
                customToastSection
                loadingSection
                containerSection
                passthroughSection
            }
            .navigationTitle("Overlayer")
        }
    }

    private var toastsSection: some View {
        Section("Toasts") {
            Button("Success") { overlay.show(SuccessToastModel(message: "Saved"), configuration: toastConfig()) }
            Button("Error") { overlay.show(ErrorToastModel(title: "Upload failed", message: "Check your connection"), configuration: toastConfig()) }
            Button("Info") { overlay.show(InfoToastModel(message: "12 items synced"), configuration: toastConfig()) }
            Button("Warning") { overlay.show(WarningToastModel(message: "Storage almost full"), configuration: toastConfig()) }
            Button("Sticky — swipe to dismiss") {
                overlay.show(
                    InfoToastModel(title: "Sticky", message: "Stays until you close it or swipe it away."),
                    configuration: toastConfig(lifetime: .sticky, isSwipeToDismissEnabled: true)
                )
            }
            Button("Tap to pause, swipe to dismiss (8s)") {
                overlay.show(
                    InfoToastModel(title: "Interactive", message: "Tap to pause or resume, hold to pause while pressed, swipe toward the edge to dismiss."),
                    configuration: toastConfig(lifetime: .seconds(8), isSwipeToDismissEnabled: true, isTapToPauseEnabled: true)
                )
            }
            Button("Show 6 (watch them queue)") {
                for index in 1...6 {
                    overlay.show(InfoToastModel(message: "Toast #\(index)"), configuration: toastConfig())
                }
            }
            Button("Dismiss all", role: .destructive) { overlay.dismissAll() }
        }
    }

    private var customToastSection: some View {
        Section("Custom toast") {
            Button("Download finished (with Open action)") {
                let model = DownloadToastModel(fileName: "report.pdf") {
                    overlay.show(SuccessToastModel(message: "Opening report.pdf…"), configuration: toastConfig())
                }
                overlay.show(model, configuration: toastConfig(lifetime: .seconds(6)))
            }
        }
    }

    private var loadingSection: some View {
        Section("Loading") {
            Button("Blocking spinner (2s)") {
                let id = overlay.showLoading(SpinnerLoadingModel(message: "Loading…"))
                hideLoading(id, after: 2)
            }
            Button("Determinate upload") { simulateUpload() }
            Button("Non-blocking (3s) — keep scrolling") {
                let config = LoadingConfiguration(isBlocking: false, backgroundStyle: AnyShapeStyle(Color.clear))
                let id = overlay.showLoading(SpinnerLoadingModel(message: "Syncing in background…"), configuration: config)
                hideLoading(id, after: 3)
            }
            Button("Custom branded loader (with Cancel)") {
                overlay.showLoading(BrandedLoadingModel(title: "Crunching numbers…"))
            }
            Button("Nested overlays (stack)") { nestedLoading() }
            Button("Hide all loading", role: .destructive) { overlay.hideAllLoading() }
        }
    }

    private var containerSection: some View {
        Section("Container config (applies to new toasts)") {
            Picker("Position", selection: $position) {
                Text("Top").tag(ToastPosition.top)
                Text("Center").tag(ToastPosition.center)
                Text("Bottom").tag(ToastPosition.bottom)
            }
            Stepper("Max visible: \(maxVisible)", value: Binding(get: { maxVisible }, set: { newValue in
                maxVisible = newValue
                Overlayer.toastContainerConfiguration.maxVisibleCount = newValue
            }), in: 1...5)
        }
    }

    private var passthroughSection: some View {
        Section("Passthrough") {
            TextField("Type while toasts are up — they don't steal focus", text: $draft)
            Text("Toasts live on a passthrough window, so this field stays interactive. A non-blocking loader behaves the same way.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    private func toastConfig(
        lifetime: ToastLifetime = .seconds(4),
        isSwipeToDismissEnabled: Bool = false,
        isTapToPauseEnabled: Bool = false
    ) -> ToastConfiguration {
        ToastConfiguration(
            position: position,
            lifetime: lifetime,
            haptic: .selection,
            isSwipeToDismissEnabled: isSwipeToDismissEnabled,
            isTapToPauseEnabled: isTapToPauseEnabled
        )
    }

    private func hideLoading(_ id: LoadingID, after seconds: Double) {
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
            overlay.hideLoading(id)
        }
    }

    private func simulateUpload() {
        let progress = LoadingProgress(fraction: 0, message: "Uploading… 0%")
        let id = overlay.showLoading(ProgressLoadingModel(progress: progress))
        Task { @MainActor in
            for step in 1...20 {
                try? await Task.sleep(nanoseconds: 90_000_000)
                progress.fraction = Double(step) / 20
                progress.message = "Uploading… \(step * 5)%"
            }
            try? await Task.sleep(nanoseconds: 250_000_000)
            overlay.hideLoading(id)
        }
    }

    private func nestedLoading() {
        let first = overlay.showLoading(SpinnerLoadingModel(message: "Step 1…"))
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            let second = overlay.showLoading(SpinnerLoadingModel(message: "Step 2…"))
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            overlay.hideLoading(second)
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            overlay.hideLoading(first)
        }
    }
}
