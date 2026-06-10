//
//  LoadingModel.swift
//  Overlayer
//
//  Created by Evgeny Blinov on 10.06.2026.
//

import Foundation

/// Marker protocol every loading-overlay data model conforms to. Like `ToastModel`, the model is plain data; its view is registered separately via `ToastServiceImpl.registerLoading(_:content:)`.
public protocol LoadingModel {}
