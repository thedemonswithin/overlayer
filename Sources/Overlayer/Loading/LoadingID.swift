//
//  LoadingID.swift
//  Overlayer
//
//  Created by Evgeny Blinov on 10.06.2026.
//

public import Foundation

/// Stable identifier for a single loading-overlay presentation.
nonisolated public struct LoadingID: Hashable, Sendable {
    public let rawValue: UUID
    
    public init(rawValue: UUID = UUID()) {
        self.rawValue = rawValue
    }
}
