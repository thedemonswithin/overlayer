//
//  LoadingHostView.swift
//  Overlayer
//
//  Created by Evgeny Blinov on 10.06.2026.
//

import SwiftUI

// Renders the loading overlay inside its window: a full-screen backdrop plus the most recent loading view centred on top. Whether touches are blocked or passed through is decided by the window (from the top overlay's isBlocking), not here.
struct LoadingHostView: View {
    @ObservedObject var presenter: LoadingPresenter

    var body: some View {
        ZStack {
            if let top = presenter.top {
                Rectangle()
                    .fill(top.configuration.backgroundStyle)
                    .ignoresSafeArea(edges: top.configuration.ignoresSafeArea ? .all : [])
                    .contentShape(Rectangle())
                    .accessibilityHidden(true)
                    .transition(.opacity)
                top.content
                    // A new identity per presentation, so a nested overlay replacing the top one cross-fades instead of swapping in place.
                    .id(top.id)
                    .transition(.opacity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(presenter.top?.configuration.animation, value: presenter.stack.count)
    }
}
