//
//  TestSupport.swift
//  Overlayer
//
//  Created by Evgeny Blinov on 05.11.2026.
//

import SwiftUI
@testable import Overlayer

struct DummyToast: ToastModel {}
struct DummyLoading: LoadingModel {}

func makeToast(on presenter: ToastPresenter, lifetime: ToastLifetime = .sticky) -> ActiveToast {
    let configuration = ToastConfiguration(lifetime: lifetime)
    let id = ToastID()
    let context = ToastContext(id: id, configuration: configuration, presenter: presenter)
    return ActiveToast(id: id, model: DummyToast(), configuration: configuration, context: context, content: AnyView(EmptyView()))
}

func makeToastPresenter(maxVisible: Int) -> ToastPresenter {
    let presenter = ToastPresenter()
    presenter.containerConfiguration = ToastContainerConfiguration(maxVisibleCount: maxVisible)
    return presenter
}

func makeLoading(on presenter: LoadingPresenter) -> ActiveLoading {
    let id = LoadingID()
    let context = LoadingContext(id: id, presenter: presenter)
    return ActiveLoading(id: id, model: DummyLoading(), configuration: .default, context: context, content: AnyView(EmptyView()))
}

/// Suspends until `install` hands over a callback and that callback is invoked once; later invocations are ignored.
func awaitCallback(_ install: (@escaping () -> Void) -> Void) async {
    await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
        var resumed = false
        install {
            guard !resumed else { return }
            resumed = true
            continuation.resume()
        }
    }
}
