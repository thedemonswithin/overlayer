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
    @State private var isDragging = false
    @State private var pressStarted: Date?
    private var position: ToastPosition { toast.configuration.position }

    var body: some View {
        toast.content
            .offset(x: dragOffset.width, y: dragOffset.height)
            .onTapGesture { handleTap() }
            .onLongPressGesture(minimumDuration: 0.2, maximumDistance: 20, pressing: { handlePressing($0) }, perform: {})
            .gesture(swipeGesture)
    }

    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 10, coordinateSpace: .local)
            .onChanged { value in
                isDragging = true
                syncPause()
                if toast.configuration.isSwipeToDismissEnabled {
                    dragOffset = rubberBanded(value.translation)
                }
            }
            .onEnded { value in
                isDragging = false
                if toast.configuration.isSwipeToDismissEnabled, shouldDismiss(value) {
                    toast.context.dismiss()
                    return
                }
                withAnimation(.interactiveSpring(response: 0.35, dampingFraction: 0.72)) {
                    dragOffset = .zero
                }
                syncPause()
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
