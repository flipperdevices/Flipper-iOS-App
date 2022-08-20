import XCTest

@testable import Core

class CellurarProviderTests: XCTestCase {
    func testNil() {
        let provider = CellurarRegionProvider { nil }
        XCTAssertNil(provider.regionCode)
    }

    func testEmpty() {
        let provider = CellurarRegionProvider { [] }
        XCTAssertNil(provider.regionCode)
    }

    func testOneSim() {
        let provider = CellurarRegionProvider { ["AD"] }
        XCTAssertEqual(provider.regionCode, ISOCode("AD"))
    }

    func testTwoEqualSim() {
        let provider = CellurarRegionProvider { ["AD", "AD"] }
        XCTAssertEqual(provider.regionCode, ISOCode("AD"))
    }

    func testTwoNotEqualSim() {
        let provider = CellurarRegionProvider { ["AD", "AE"] }
        XCTAssertNil(provider.regionCode)
    }
}
