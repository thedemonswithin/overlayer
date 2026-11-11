//
//  ToastItemView.swift
//  Overlayer
//
//  Created by Evgeny Blinov on 10.06.2026.
//

import SwiftUI

struct ToastItemView: View {
    let toast: ActiveToast
    @State private var dragOffset: CGSize = .zero
    @State private var isHolding = false
    @State private var isStuckPaused = false
    // Gesture state resets on its own when the drag ends or is cancelled (system gesture, interruption), so the toast cannot get stuck paused; `onEnded` alone is not called on cancellation.
    @GestureState private var isDragging = false
    @State private var isDismissing = false
    @State private var pressStarted: Date?
    private var position: ToastPosition { toast.configuration.position }

    var body: some View {
        toast.content
            .offset(x: dragOffset.width, y: dragOffset.height)
            .onTapGesture { handleTap() }
            .onLongPressGesture(minimumDuration: 0.2, maximumDistance: 20, pressing: { handlePressing($0) }, perform: {})
            // Attached only when swipe-to-dismiss is on, so a disabled swipe neither pauses the toast nor competes with the app's own gestures.
            .gesture(swipeGesture, including: toast.configuration.isSwipeToDismissEnabled ? .all : .subviews)
            .onChange(of: isDragging) { dragging in
                if !dragging { springBackIfNeeded() }
                syncPause()
            }
            // Gestures are unreachable with VoiceOver, so the same controls are offered as accessibility actions; the escape gesture (two-finger scrub) dismisses.
            .accessibilityElement(children: .contain)
            .accessibilityAction(.escape) { toast.context.dismiss() }
            .accessibilityAction(named: Text("Dismiss", bundle: .module)) { toast.context.dismiss() }
            .modifier(PauseAction(context: toast.context, isProgressive: toast.context.isProgressive, toggle: togglePauseFromAccessibility))
    }

    private func togglePauseFromAccessibility() {
        isStuckPaused.toggle()
        syncPause()
    }

    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 10, coordinateSpace: .local)
            .updating($isDragging) { _, dragging, _ in dragging = true }
            .onChanged { value in
                dragOffset = rubberBanded(value.translation)
            }
            .onEnded { value in
                guard shouldDismiss(value) else { return }
                isDismissing = true
                toast.context.dismiss()
            }
    }

    // Runs once the drag is over, whether it ended or was cancelled: unless the toast is on its way out, it returns to its place.
    private func springBackIfNeeded() {
        guard !isDismissing, dragOffset != .zero else { return }
        withAnimation(.interactiveSpring(response: 0.35, dampingFraction: 0.72)) {
            dragOffset = .zero
        }
    }

    // A quick tap toggles a sticky pause; a hold is handled by the long-press gesture, so ignore taps that were actually long presses.
    private func handleTap() {
        guard toast.configuration.isTapToPauseEnabled else { return }
        let heldFor = pressStarted.map { Date.now.timeIntervalSince($0) } ?? 0
        guard heldFor < 0.2 else { return }
        isStuckPaused.toggle()
        syncPause()
    }

    private func handlePressing(_ pressing: Bool) {
        if pressing { pressStarted = .now }
        isHolding = pressing && toast.configuration.isHoldToPauseEnabled
        syncPause()
    }

    // Pause sources combine: hold-to-read, sticky tap, and the active drag — pausing while dragging keeps the progress bar in step with the card instead of draining underneath it.
    private func syncPause() {
        if isHolding || isStuckPaused || isDragging {
            toast.context.pause()
        } else {
            toast.context.resume()
        }
    }

    // Follow the finger toward the dismiss edge; resist (rubber-band, asymptotic) in every other direction so an opposite pull springs back on release.
    private func rubberBanded(_ translation: CGSize) -> CGSize {
        let height: CGFloat
        switch position {
        case .top: height = translation.height <= 0 ? translation.height : rubberBand(translation.height)
        case .bottom: height = translation.height >= 0 ? translation.height : rubberBand(translation.height)
        case .center: height = translation.height
        }
        return CGSize(width: rubberBand(translation.width), height: height)
    }

    private func rubberBand(_ value: CGFloat, dimension: CGFloat = 140, coefficient: CGFloat = 0.55) -> CGFloat {
        guard value != 0 else { return 0 }
        let sign: CGFloat = value < 0 ? -1 : 1
        let magnitude = abs(value)
        return sign * (1 - 1 / (magnitude * coefficient / dimension + 1)) * dimension
    }

    private func shouldDismiss(_ value: DragGesture.Value) -> Bool {
        let translation = value.translation.height
        let predicted = value.predictedEndTranslation.height
        switch position {
        case .top: return translation < -60 || predicted < -150
        case .bottom: return translation > 60 || predicted > 150
        case .center: return abs(translation) > 60 || abs(predicted) > 150
        }
    }
}

// Pause / Resume action for auto-dismissing toasts; its name follows the current state.
private struct PauseAction: ViewModifier {
    @ObservedObject var context: ToastContext
    let isProgressive: Bool
    let toggle: () -> Void

    func body(content: Content) -> some View {
        if isProgressive {
            content.accessibilityAction(named: context.isPaused ? Text("Resume", bundle: .module) : Text("Pause", bundle: .module), toggle)
        } else {
            content
        }
    }
}
