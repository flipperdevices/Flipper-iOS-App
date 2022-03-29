import XCTest

@testable import Core

class FlipperTests: XCTestCase {
    func testEquatable() {
        let first = Flipper(id: UUID(), name: "first", color: .unknown)
        let second = Flipper(id: first.id, name: "second", color: .unknown)

        XCTAssertNotEqual(first, second)
    }
}
