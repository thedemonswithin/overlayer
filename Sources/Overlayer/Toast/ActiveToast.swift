//
//  ActiveToast.swift
//  Overlayer
//
//  Created by Evgeny Blinov on 10.06.2026.
//

import SwiftUI

// One live presentation: the model, its resolved view, and the context that also carries its lifetime timer.
final class ActiveToast: Identifiable {
    let id: ToastID
    let model: any ToastModel
    let configuration: ToastConfiguration
    let context: ToastContext
    let content: AnyView

    init(
        id: ToastID,
        model: any ToastModel,
        configuration: ToastConfiguration,
        context: ToastContext,
        content: AnyView
    ) {
        self.id = id
        self.model = model
        self.configuration = configuration
        self.context = context
        self.content = content
    }
}
