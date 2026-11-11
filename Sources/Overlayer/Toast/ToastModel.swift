//
//  ToastModel.swift
//  Overlayer
//
//  Created by Evgeny Blinov on 10.06.2026.
//

import Foundation

/// Marker protocol every toast data model conforms to. A model carries only data; its visual representation is supplied separately via `Overlayer.registerToast(_:content:)`, which keeps view and model fully decoupled and free of any enum or built-in switch.
///
/// The protocol is `nonisolated`, so models can be created anywhere; make your model `Sendable` to pass it between actors.
nonisolated public protocol ToastModel {
    /// Text VoiceOver announces when the toast appears. Defaults to `nil` (nothing is announced); return a short summary such as the toast's title and message.
    var accessibilityAnnouncement: String? { get }
}

nonisolated public extension ToastModel {
    var accessibilityAnnouncement: String? { nil }
}
