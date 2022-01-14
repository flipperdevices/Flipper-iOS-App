import XCTest

@testable import Core

class PeripheralTests: XCTestCase {
    func testEquatable() {
        let first = Peripheral(id: UUID(), name: "first", color: .unknown)
        let second = Peripheral(id: first.id, name: "second", color: .unknown)

        XCTAssertNotEqual(first, second)
    }
}
