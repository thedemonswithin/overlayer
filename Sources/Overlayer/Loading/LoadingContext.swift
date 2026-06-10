//
//  LoadingContext.swift
//  Overlayer
//
//  Created by Evgeny Blinov on 10.06.2026.
//

import Foundation

/// Handle handed to every loading view, letting it dismiss its own overlay (e.g. from a cancel button).
@MainActor public final class LoadingContext {
    public let id: LoadingID
    private weak var presenter: LoadingPresenter?

    init(id: LoadingID, presenter: LoadingPresenter) {
        self.id = id
        self.presenter = presenter
    }

    /// Hide this loading overlay immediately (animated).
    public func dismiss() {
        presenter?.hide(id: id)
    }
}
