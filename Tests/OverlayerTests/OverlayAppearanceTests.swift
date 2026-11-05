//
//  OverlayAppearanceTests.swift
//  Overlayer
//
//  Created by Evgeny Blinov on 05.11.2026.
//

import UIKit
import XCTest

@testable import Overlayer

@MainActor final class OverlayAppearanceTests: XCTestCase {
    private final class Container: UIViewController {
        var child: UIViewController?
        override var childForStatusBarStyle: UIViewController? { child }
    }

    private final class SelfReferencing: UIViewController {
        override var childForStatusBarStyle: UIViewController? { self }
    }

    func testResolveFollowsChildDelegation() {
        let leaf = UIViewController()
        let middle = Container()
        middle.child = leaf
        let root = Container()
        root.child = middle
        XCTAssertTrue(OverlayAppearance.resolve(root, child: \.childForStatusBarStyle) === leaf)
    }

    func testResolveStopsWithoutDelegation() {
        let root = UIViewController()
        XCTAssertTrue(OverlayAppearance.resolve(root, child: \.childForStatusBarStyle) === root)
    }

    func testResolveStopsOnSelfReference() {
        let root = SelfReferencing()
        XCTAssertTrue(OverlayAppearance.resolve(root, child: \.childForStatusBarStyle) === root)
    }

    func testTopmostWithoutPresentationIsRoot() {
        let root = UIViewController()
        XCTAssertTrue(OverlayAppearance.topmost(from: root) === root)
    }

    func testNoWindowMeansNoAppController() {
        XCTAssertNil(OverlayAppearance.appController(below: nil))
    }
}
