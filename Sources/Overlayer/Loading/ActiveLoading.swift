//
//  ActiveLoading.swift
//  Overlayer
//
//  Created by Evgeny Blinov on 10.06.2026.
//

import SwiftUI

/// Internal record for one live loading presentation.
@MainActor final class ActiveLoading: Identifiable {
    let id: LoadingID
    let model: any LoadingModel
    let configuration: LoadingConfiguration
    let context: LoadingContext
    let content: AnyView

    init(
        id: LoadingID,
        model: any LoadingModel,
        configuration: LoadingConfiguration,
        context: LoadingContext,
        content: AnyView
    ) {
        self.id = id
        self.model = model
        self.configuration = configuration
        self.context = context
        self.content = content
    }
}
