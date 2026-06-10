//
//  PassthroughRelayTests.swift
//  Overlayer
//
//  Created by Evgeny Blinov on 10.06.2026.
//

import CoreGraphics
import XCTest

@testable import Overlayer

final class PassthroughRelayTests: XCTestCase {
    func testCapturesOnlyInsideCardFrames() {
        let relay = PassthroughRelay()
        relay.interactiveFrames = [ToastID(): CGRect(x: 10, y: 20, width: 100, height: 50)]
        XCTAssertTrue(relay.capturesTouch(at: CGPoint(x: 50, y: 40)))
        XCTAssertFalse(relay.capturesTouch(at: CGPoint(x: 5, y: 5)))
        XCTAssertFalse(relay.capturesTouch(at: CGPoint(x: 200, y: 200)))
    }

    func testEmptyRelayCapturesNothing() {
        XCTAssertFalse(PassthroughRelay().capturesTouch(at: .zero))
    }

    func testCapturesAcrossMultipleFrames() {
        let relay = PassthroughRelay()
        relay.interactiveFrames = [ToastID(): CGRect(x: 0, y: 0, width: 10, height: 10), ToastID(): CGRect(x: 100, y: 100, width: 10, height: 10)]
        XCTAssertTrue(relay.capturesTouch(at: CGPoint(x: 5, y: 5)))
        XCTAssertTrue(relay.capturesTouch(at: CGPoint(x: 105, y: 105)))
        XCTAssertFalse(relay.capturesTouch(at: CGPoint(x: 50, y: 50)))
    }
}
