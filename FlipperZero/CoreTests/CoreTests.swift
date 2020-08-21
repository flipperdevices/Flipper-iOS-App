//
//  CoreTests.swift
//  CoreTests
//
//  Created by Eugene Berdnikov on 8/21/20.
//

@testable import Core
import SwiftUI
import XCTest

// TODO: remove this dummy test when more meaningful tests are added
class CoreTests: XCTestCase {
    func testRootViewReturnsTabViewAsBody() throws {
        let target = RootView()
        XCTAssertEqual(target.homeTabTitle, "Home")
    }
}
