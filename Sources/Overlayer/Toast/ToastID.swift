//
//  ToastID.swift
//  Overlayer
//
//  Created by Evgeny Blinov on 10.06.2026.
//

import Foundation

/// Stable identifier for a single toast presentation. Two `show` calls with equal models still produce distinct ids.
public struct ToastID: Hashable, Sendable {
    public let rawValue: UUID
    public init(rawValue: UUID = UUID()) { self.rawValue = rawValue }
}
