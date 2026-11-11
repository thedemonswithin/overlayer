//
//  OverlayerExampleApp.swift
//  OverlayerExample
//
//  Created by Evgeny Blinov on 10.06.2026.
//

import Overlayer
import OverlayerDefaults
import SwiftUI

@main
struct OverlayerExampleApp: App {
    init() {
        Overlayer.registerDefaultToasts()
        Overlayer.registerDefaultLoading()
        Overlayer.registerToast(DownloadToastModel.self) { model, context in
            DownloadToastView(model: model, context: context)
        }
        Overlayer.registerLoading(BrandedLoadingModel.self) { model, context in
            BrandedLoadingView(model: model, context: context)
        }
    }

    var body: some Scene {
        WindowGroup {
            if let scene = ShowcaseScene.current {
                ShowcaseView(scene: scene)
            } else {
                ContentView()
            }
        }
    }
}
