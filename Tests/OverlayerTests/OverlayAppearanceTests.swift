//
//  OverlayAppearanceTests.swift
//  Overlayer
//
//  Created by Evgeny Blinov on 05.11.2026.
//

import Testing
import UIKit
@testable import Overlayer

@Suite struct OverlayAppearanceTests {
    private final class Container: UIViewController {
        var child: UIViewController?
        override var childForStatusBarStyle: UIViewController? { child }
    }

    private final class SelfReferencing: UIViewController {
        override var childForStatusBarStyle: UIViewController? { self }
    }

    @Test func resolveFollowsChildDelegation() {
        let leaf = UIViewController()
        let middle = Container()
        middle.child = leaf
        let root = Container()
        root.child = middle
        #expect(OverlayAppearance.resolve(root, child: \.childForStatusBarStyle) === leaf)
    }

    @Test func resolveStopsWithoutDelegation() {
        let root = UIViewController()
        #expect(OverlayAppearance.resolve(root, child: \.childForStatusBarStyle) === root)
    }

    @Test func resolveStopsOnSelfReference() {
        let root = SelfReferencing()
        #expect(OverlayAppearance.resolve(root, child: \.childForStatusBarStyle) === root)
    }

    @Test func topmostWithoutPresentationIsRoot() {
        let root = UIViewController()
        #expect(OverlayAppearance.topmost(from: root) === root)
    }

    @Test func noWindowMeansNoAppController() {
        #expect(OverlayAppearance.appController(below: nil) == nil)
    }
}
