//
//  ExampleLoading.swift
//  Overlayer
//
//  Created by Evgeny Blinov on 10.06.2026.
//

import SwiftUI

public struct SpinnerLoadingModel: LoadingModel {
    public var message: String?

    public init(message: String? = nil) {
        self.message = message
    }
}

public struct SpinnerLoadingView: View {
    private let model: SpinnerLoadingModel

    public init(model: SpinnerLoadingModel, context: LoadingContext) {
        self.model = model
    }

    public var body: some View {
        LoadingCard {
            ProgressView().controlSize(.large)
            if let message = model.message {
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

/// Observable progress source for determinate loading (file up/download, long tasks). Retain it, pass it inside `ProgressLoadingModel`, and update `fraction` / `message` while the overlay is shown.
public final class LoadingProgress: ObservableObject {
    @Published public var fraction: Double
    @Published public var message: String?

    public init(fraction: Double = 0, message: String? = nil) {
        self.fraction = fraction
        self.message = message
    }
}

public struct ProgressLoadingModel: LoadingModel {
    public var progress: LoadingProgress

    public init(progress: LoadingProgress) {
        self.progress = progress
    }
}

public struct ProgressLoadingView: View {
    @ObservedObject private var progress: LoadingProgress

    public init(model: ProgressLoadingModel, context: LoadingContext) {
        _progress = ObservedObject(wrappedValue: model.progress)
    }

    public var body: some View {
        LoadingCard {
            ProgressView(value: min(1, max(0, progress.fraction)))
                .progressViewStyle(.linear)
                .frame(width: 200)
            if let message = progress.message {
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

public extension Overlayer {
    /// Register the example loading views: an indeterminate spinner and a determinate progress overlay.
    static func registerExampleLoading() {
        registerLoading(SpinnerLoadingModel.self) { SpinnerLoadingView(model: $0, context: $1) }
        registerLoading(ProgressLoadingModel.self) { ProgressLoadingView(model: $0, context: $1) }
    }
}

// Shared centred card chrome for the example loading views.
private struct LoadingCard<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        VStack(spacing: 14) {
            content
        }
        .padding(24)
        .frame(minWidth: 120)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.2), radius: 16, x: 0, y: 8)
    }
}
