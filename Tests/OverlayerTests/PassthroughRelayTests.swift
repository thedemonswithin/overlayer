//
//  PassthroughRelayTests.swift
//  Overlayer
//
//  Created by Evgeny Blinov on 10.06.2026.
//

import CoreGraphics
import Testing
@testable import Overlayer

@Suite struct PassthroughRelayTests {
    @Test func capturesOnlyInsideCardFrames() {
        let relay = PassthroughRelay()
        relay.interactiveFrames = [ToastID(): CGRect(x: 10, y: 20, width: 100, height: 50)]
        #expect(relay.capturesTouch(at: CGPoint(x: 50, y: 40)))
        #expect(!relay.capturesTouch(at: CGPoint(x: 5, y: 5)))
        #expect(!relay.capturesTouch(at: CGPoint(x: 200, y: 200)))
    }

    @Test func emptyRelayCapturesNothing() {
        #expect(!PassthroughRelay().capturesTouch(at: .zero))
    }

    @Test func capturesAcrossMultipleFrames() {
        let relay = PassthroughRelay()
        relay.interactiveFrames = [
            ToastID(): CGRect(x: 0, y: 0, width: 10, height: 10),
            ToastID(): CGRect(x: 100, y: 100, width: 10, height: 10)
        ]
        #expect(relay.capturesTouch(at: CGPoint(x: 5, y: 5)))
        #expect(relay.capturesTouch(at: CGPoint(x: 105, y: 105)))
        #expect(!relay.capturesTouch(at: CGPoint(x: 50, y: 50)))
    }
}
