import XCTest

@testable import Core

class CellularProviderTests: XCTestCase {
    func testNil() {
        let provider = CellularRegionProvider { nil }
        XCTAssertNil(provider.regionCode)
    }

    func testEmpty() {
        let provider = CellularRegionProvider { [] }
        XCTAssertNil(provider.regionCode)
    }

    func testOneSim() {
        let provider = CellularRegionProvider { ["AD"] }
        XCTAssertEqual(provider.regionCode, ISOCode("AD"))
    }

    func testTwoEqualSim() {
        let provider = CellularRegionProvider { ["AD", "AD"] }
        XCTAssertEqual(provider.regionCode, ISOCode("AD"))
    }

    func testTwoNotEqualSim() {
        let provider = CellularRegionProvider { ["AD", "AE"] }
        XCTAssertNil(provider.regionCode)
    }
}
