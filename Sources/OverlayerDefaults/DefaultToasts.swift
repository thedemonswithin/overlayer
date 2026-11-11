//
//  DefaultToasts.swift
//  OverlayerDefaults
//
//  Created by Evgeny Blinov on 10.06.2026.
//

public import Overlayer
public import SwiftUI

nonisolated public struct SuccessToastModel: ToastModel, Sendable {
    public var title: String?
    public var message: String

    public var accessibilityAnnouncement: String? {
        [title, message].compactMap(\.self).joined(separator: ". ")
    }

    public init(title: String? = nil, message: String) {
        self.title = title
        self.message = message
    }
}

nonisolated public struct ErrorToastModel: ToastModel, Sendable {
    public var title: String?
    public var message: String

    public var accessibilityAnnouncement: String? {
        [title, message].compactMap(\.self).joined(separator: ". ")
    }

    public init(title: String? = nil, message: String) {
        self.title = title
        self.message = message
    }
}

nonisolated public struct InfoToastModel: ToastModel, Sendable {
    public var title: String?
    public var message: String

    public var accessibilityAnnouncement: String? {
        [title, message].compactMap(\.self).joined(separator: ". ")
    }

    public init(title: String? = nil, message: String) {
        self.title = title
        self.message = message
    }
}

nonisolated public struct WarningToastModel: ToastModel, Sendable {
    public var title: String?
    public var message: String

    public var accessibilityAnnouncement: String? {
        [title, message].compactMap(\.self).joined(separator: ". ")
    }

    public init(title: String? = nil, message: String) {
        self.title = title
        self.message = message
    }
}

public struct SuccessToastView: View {
    private let model: SuccessToastModel
    private let context: ToastContext

    public init(model: SuccessToastModel, context: ToastContext) {
        self.model = model
        self.context = context
    }

    public var body: some View {
        DefaultToastBody(icon: "checkmark.circle.fill", tint: .green, title: model.title, message: model.message, context: context)
    }
}

public struct ErrorToastView: View {
    private let model: ErrorToastModel
    private let context: ToastContext

    public init(model: ErrorToastModel, context: ToastContext) {
        self.model = model
        self.context = context
    }

    public var body: some View {
        DefaultToastBody(icon: "xmark.octagon.fill", tint: .red, title: model.title, message: model.message, context: context)
    }
}

public struct InfoToastView: View {
    private let model: InfoToastModel
    private let context: ToastContext

    public init(model: InfoToastModel, context: ToastContext) {
        self.model = model
        self.context = context
    }

    public var body: some View {
        DefaultToastBody(icon: "info.circle.fill", tint: .blue, title: model.title, message: model.message, context: context)
    }
}

public struct WarningToastView: View {
    private let model: WarningToastModel
    private let context: ToastContext

    public init(model: WarningToastModel, context: ToastContext) {
        self.model = model
        self.context = context
    }

    public var body: some View {
        DefaultToastBody(icon: "exclamationmark.triangle.fill", tint: .orange, title: model.title, message: model.message, context: context)
    }
}

public extension Overlayer {
    /// Register the default toast types (Success / Error / Info / Warning). Optional: register your own types instead or in addition.
    static func registerDefaultToasts() {
        registerToast(SuccessToastModel.self) { SuccessToastView(model: $0, context: $1) }
        registerToast(ErrorToastModel.self) { ErrorToastView(model: $0, context: $1) }
        registerToast(InfoToastModel.self) { InfoToastView(model: $0, context: $1) }
        registerToast(WarningToastModel.self) { WarningToastView(model: $0, context: $1) }
    }

    @available(*, deprecated, renamed: "registerDefaultToasts()")
    static func registerExampleToasts() { registerDefaultToasts() }
}

// Shared body for the default toasts: icon, optional title, and message, wrapped in a tinted `ToastCard`.
struct DefaultToastBody: View {
    let icon: String
    let tint: Color
    let title: String?
    let message: String
    let context: ToastContext

    var body: some View {
        ToastCard(context: context, accent: tint) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(tint)
                    .padding(.top, 1)
                VStack(alignment: .leading, spacing: 2) {
                    if let title {
                        Text(title).font(.subheadline.weight(.semibold))
                    }
                    Text(message)
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
            }
        }
    }
}
