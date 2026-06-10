//
//  OverlayRegistry.swift
//  Overlayer
//
//  Created by Evgeny Blinov on 10.06.2026.
//

import SwiftUI

// Generic type-keyed map from a concrete model type to a view builder. One class serves every overlay kind (toasts, loading, …); the Context type is what differs per kind.
@MainActor final class OverlayRegistry<Context> {
    private var builders: [ObjectIdentifier: (Any, Context) -> AnyView] = [:]

    func register<Model>(
        _ type: Model.Type,
        builder: @escaping (Model, Context) -> AnyView
    ) {
        builders[ObjectIdentifier(type)] = { model, context in
            guard let typed = model as? Model else { return AnyView(EmptyView()) }
            return builder(typed, context)
        }
    }

    func makeView(for model: Any, context: Context) -> AnyView? {
        builders[ObjectIdentifier(type(of: model))]?(model, context)
    }
}
