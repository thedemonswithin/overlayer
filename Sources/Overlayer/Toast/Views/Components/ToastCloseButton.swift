//
//  ToastCloseButton.swift
//  Overlayer
//
//  Created by Evgeny Blinov on 10.06.2026.
//

import SwiftUI

public struct ToastCloseButton: View {
    private let context: ToastContext
    
    public init(context: ToastContext) {
        self.context = context
    }
    
    public var body: some View {
        Button {
            context.dismiss()
        } label: {
            Image(systemName: "xmark")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(.secondary)
                .padding(7)
                .background(.thinMaterial, in: Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text("Close"))
    }
}
