import XCTest

@testable import Core

class PeripheralTests: XCTestCase {
    func testEquatable() {
        let first = Peripheral(id: UUID(), name: "first")
        let second = Peripheral(id: first.id, name: "second")

        XCTAssertNotEqual(first, second)
    }
}
