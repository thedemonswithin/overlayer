//
//  ToastConfigurationTests.swift
//  Overlayer
//
//  Created by Evgeny Blinov on 10.06.2026.
//

import XCTest

@testable import Overlayer

final class ToastConfigurationTests: XCTestCase {
    func testToastDefaults() {
        let configuration = ToastConfiguration.default
        XCTAssertEqual(configuration.position, .bottom)
        XCTAssertEqual(configuration.lifetime, .seconds(4))
        XCTAssertFalse(configuration.isSwipeToDismissEnabled)
        XCTAssertFalse(configuration.isTapToPauseEnabled)
        XCTAssertTrue(configuration.isHoldToPauseEnabled)
        XCTAssertTrue(configuration.showsCloseButton)
        XCTAssertTrue(configuration.showsProgressBar)
    }

    func testContainerDefaults() {
        let container = ToastContainerConfiguration.default
        XCTAssertEqual(container.maxVisibleCount, 3)
        XCTAssertEqual(container.spacing, 8)
    }

    func testLifetimeDuration() {
        XCTAssertEqual(ToastLifetime.seconds(3).duration, 3)
        XCTAssertNil(ToastLifetime.sticky.duration)
    }
}
