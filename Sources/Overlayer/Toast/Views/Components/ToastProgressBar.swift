//
//  ToastProgressBar.swift
//  Overlayer
//
//  Created by Evgeny Blinov on 10.06.2026.
//

public import SwiftUI

/// Bar that drains with the toast's lifetime. It redraws on display frames only while it is on screen and the toast is running; when paused or sticky it costs nothing.
public struct ToastProgressBar: View {
    @ObservedObject private var context: ToastContext
    private let tint: Color

    public init(context: ToastContext, tint: Color = .accentColor) {
        self.context = context
        self.tint = tint
    }

    public var body: some View {
        TimelineView(.animation(minimumInterval: nil, paused: context.isPaused || !context.isProgressive)) { _ in
            // Read the progress here, in the closure the timeline re-runs every frame, and hand it down as a value: a view whose inputs did not change (e.g. a GeometryReader holding only the context reference) is not re-evaluated, so the bar would only move when `isPaused` flips.
            ProgressFill(progress: context.progress, tint: tint.opacity(context.isPaused ? 0.5 : 0.9))
        }
    }
}

private struct ProgressFill: View {
    let progress: Double
    let tint: Color

    var body: some View {
        GeometryReader { proxy in
            Rectangle()
                .fill(tint)
                .frame(width: max(0, proxy.size.width * progress))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
