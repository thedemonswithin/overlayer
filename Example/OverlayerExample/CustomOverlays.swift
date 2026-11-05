//
//  CustomOverlays.swift
//  OverlayerExample
//
//  Created by Evgeny Blinov on 10.06.2026.
//

import Overlayer
import SwiftUI

// A custom toast type: plain data model + its own view with an action button, registered independently of any enum.
struct DownloadToastModel: ToastModel {
    let fileName: String
    let onOpen: () -> Void

    var accessibilityAnnouncement: String? { "Download finished: \(fileName)" }
}

struct DownloadToastView: View {
    let model: DownloadToastModel
    let context: ToastContext

    var body: some View {
        ToastCard(context: context, accent: .indigo) {
            HStack(spacing: 12) {
                Image(systemName: "arrow.down.circle.fill")
                    .font(.title3)
                    .foregroundStyle(.indigo)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Download finished").font(.subheadline.weight(.semibold))
                    Text(model.fileName).font(.caption).foregroundStyle(.secondary)
                }
                Spacer(minLength: 0)
                Button("Open") { model.onOpen(); context.dismiss() }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
            }
        }
    }
}

// A custom (blocking) loading type with a Cancel button driven through the LoadingContext.
struct BrandedLoadingModel: LoadingModel {
    let title: String

    var accessibilityAnnouncement: String? { title }
}

struct BrandedLoadingView: View {
    let model: BrandedLoadingModel
    let context: LoadingContext

    var body: some View {
        VStack(spacing: 16) {
            ProgressView().controlSize(.large)
            Text(model.title).font(.headline)
            Button("Cancel") { context.dismiss() }
                .buttonStyle(.bordered)
        }
        .padding(28)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.2), radius: 18, x: 0, y: 8)
    }
}
