//
//  ToastModel.swift
//  Overlayer
//
//  Created by Evgeny Blinov on 10.06.2026.
//

import Foundation

/// Marker protocol every toast data model conforms to. A model carries only data; its visual representation is supplied separately via `ToastService.register(_:content:)`, which keeps view and model fully decoupled and free of any enum or built-in switch.
public protocol ToastModel {}
