import XCTest
@testable import Core

class PeripheralTests: XCTestCase {
    func testEquatableByID() {
        XCTAssertTrue(Peripheral() as Any as EquatableById != nil)
    }
}
