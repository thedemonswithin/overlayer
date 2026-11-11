//
//  LoadingModel.swift
//  Overlayer
//
//  Created by Evgeny Blinov on 10.06.2026.
//

import Foundation

/// Marker protocol every loading-overlay data model conforms to. Like `ToastModel`, the model is plain data; its view is registered separately via `Overlayer.registerLoading(_:content:)`.
nonisolated public protocol LoadingModel {
    /// Text VoiceOver announces when a non-blocking loader appears (a blocking one moves VoiceOver focus into the loader instead). Defaults to `nil`.
    var accessibilityAnnouncement: String? { get }
}

nonisolated public extension LoadingModel {
    var accessibilityAnnouncement: String? { nil }
}
