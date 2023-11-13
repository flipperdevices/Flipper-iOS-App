import XCTest

@testable import Core

class ISOCodeTests: XCTestCase {
    func testPossibleISOCode() {
        XCTAssertNotNil(ISOCode("AA"))
        XCTAssertNotNil(ISOCode("BB"))
        XCTAssertNotNil(ISOCode("CC"))
    }

    func testInvalidISOCode() {
        XCTAssertNil(ISOCode(String("")))
        XCTAssertNil(ISOCode(String("A")))
        XCTAssertNil(ISOCode(String("invalid")))
    }
}
