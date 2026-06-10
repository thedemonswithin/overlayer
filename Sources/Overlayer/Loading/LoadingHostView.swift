//
//  LoadingHostView.swift
//  Overlayer
//
//  Created by Evgeny Blinov on 10.06.2026.
//

import SwiftUI

// Renders the loading overlay inside its window: a full-screen backdrop plus the most recent loading view centred on top. Hit-testing is enabled only in blocking mode; when the top loading is non-blocking the whole overlay opts out so its window lets touches fall through.
struct LoadingHostView: View {
    @ObservedObject var presenter: LoadingPresenter

    var body: some View {
        ZStack {
            if let top = presenter.top {
                Rectangle()
                    .fill(top.configuration.backgroundStyle)
                    .ignoresSafeArea(edges: top.configuration.ignoresSafeArea ? .all : [])
                    .contentShape(Rectangle())
                    .transition(.opacity)
                top.content
                    .transition(.opacity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .allowsHitTesting(presenter.top?.configuration.isBlocking ?? true)
        .animation(presenter.top?.configuration.animation, value: presenter.stack.count)
    }
}
