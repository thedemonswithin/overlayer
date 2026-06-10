//
//  ToastCard.swift
//  Overlayer
//
//  Created by Evgeny Blinov on 10.06.2026.
//

import SwiftUI

public struct ToastCard<Content: View>: View {
    private let context: ToastContext
    private let accent: Color
    private let background: AnyShapeStyle
    private let cornerRadius: CGFloat
    private let content: Content

    public init(
        context: ToastContext,
        accent: Color = .accentColor,
        background: AnyShapeStyle = AnyShapeStyle(Material.regular),
        cornerRadius: CGFloat = 14,
        @ViewBuilder content: () -> Content
    ) {
        self.context = context
        self.accent = accent
        self.background = background
        self.cornerRadius = cornerRadius
        self.content = content()
    }

    public var body: some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 12) {
                content
                
                if context.showsCloseButton {
                    ToastCloseButton(context: context)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            
            if context.showsProgressBar, context.isProgressive {
                ToastProgressBar(context: context, tint: accent).frame(height: 3)
            }
        }
        .background(background, in: shape)
        .clipShape(shape)
        .shadow(color: .black.opacity(0.18), radius: 12, x: 0, y: 6)
    }
}
