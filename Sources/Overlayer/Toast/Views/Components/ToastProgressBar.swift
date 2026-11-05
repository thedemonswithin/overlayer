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
            GeometryReader { proxy in
                Rectangle()
                    .fill(tint.opacity(context.isPaused ? 0.5 : 0.9))
                    .frame(width: max(0, proxy.size.width * context.progress))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}
