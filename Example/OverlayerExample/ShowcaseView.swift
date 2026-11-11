//
//  ShowcaseView.swift
//  OverlayerExample
//
//  Created by Evgeny Blinov on 11.11.2026.
//

import Overlayer
import OverlayerDefaults
import SwiftUI

// Scenes for the README screenshots: a realistic screen with overlays already on it. Launch with `-showcase <scene>`, e.g. `xcrun simctl launch booted <bundle id> -showcase toasts`.
enum ShowcaseScene: String {
    case toasts, error, custom, progress, branded

    static var current: ShowcaseScene? {
        UserDefaults.standard.string(forKey: "showcase").flatMap(ShowcaseScene.init(rawValue:))
    }
}

struct ShowcaseView: View {
    let scene: ShowcaseScene

    private var overlay: any OverlayService { Overlayer.service }

    var body: some View {
        NavigationStack {
            List {
                Section("Recent") {
                    ForEach(Document.recent) { DocumentRow(document: $0) }
                }
                Section("Shared with me") {
                    ForEach(Document.shared) { DocumentRow(document: $0) }
                }
            }
            .navigationTitle("Documents")
            // A top toast would cover half of a large title; the compact one keeps the scene tidy.
            .navigationBarTitleDisplayMode(scene == .error ? .inline : .large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add", systemImage: "plus") {}
                }
            }
        }
        .task { await present() }
    }

    private func present() async {
        try? await Task.sleep(nanoseconds: 400_000_000)
        switch scene {
        case .toasts:
            let bottom = ToastConfiguration(position: .bottom, lifetime: .seconds(30))
            overlay.show(InfoToastModel(message: "12 items synced"), configuration: bottom)
            overlay.show(WarningToastModel(message: "Storage almost full"), configuration: bottom)
            overlay.show(SuccessToastModel(message: "Saved"), configuration: bottom)
        case .error:
            overlay.show(
                ErrorToastModel(title: "Upload failed", message: "Check your connection"),
                configuration: ToastConfiguration(position: .top, lifetime: .seconds(30))
            )
        case .custom:
            overlay.show(
                DownloadToastModel(fileName: "Q3 Report.pdf") {},
                configuration: ToastConfiguration(position: .bottom, lifetime: .seconds(30))
            )
        case .progress:
            let progress = LoadingProgress(fraction: 0.62, message: "Uploading… 62%")
            overlay.showLoading(ProgressLoadingModel(progress: progress))
        case .branded:
            overlay.showLoading(BrandedLoadingModel(title: "Crunching numbers…"))
        }
    }
}

private struct Document: Identifiable {
    let name: String
    let detail: String
    let icon: String
    let tint: Color

    var id: String { name }

    static let recent = [
        Document(name: "Q3 Report.pdf", detail: "2.4 MB · Today, 9:12", icon: "doc.richtext.fill", tint: .red),
        Document(name: "Budget 2027.xlsx", detail: "860 KB · Yesterday", icon: "tablecells.fill", tint: .green),
        Document(name: "Launch Keynote.key", detail: "48 MB · Mon", icon: "play.rectangle.fill", tint: .blue),
        Document(name: "Team Offsite", detail: "34 photos · Sun", icon: "photo.on.rectangle.angled", tint: .orange),
        Document(name: "Release Notes.md", detail: "12 KB · Nov 7", icon: "doc.text.fill", tint: .gray)
    ]

    static let shared = [
        Document(name: "Brand Guidelines.pdf", detail: "Anna · 5.1 MB", icon: "paintpalette.fill", tint: .purple),
        Document(name: "Interview Notes", detail: "Mark · 3 KB", icon: "note.text", tint: .yellow),
        Document(name: "Roadmap.numbers", detail: "Lena · 1.2 MB", icon: "chart.bar.doc.horizontal.fill", tint: .teal),
        Document(name: "Contract Draft.docx", detail: "Legal · 220 KB", icon: "doc.fill", tint: .indigo)
    ]
}

private struct DocumentRow: View {
    let document: Document

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: document.icon)
                .font(.title3)
                .foregroundStyle(.white)
                .frame(width: 40, height: 40)
                .background(document.tint.gradient, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            VStack(alignment: .leading, spacing: 2) {
                Text(document.name).font(.body.weight(.medium))
                Text(document.detail).font(.caption).foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
            Image(systemName: "ellipsis").foregroundStyle(.tertiary)
        }
        .padding(.vertical, 2)
    }
}
