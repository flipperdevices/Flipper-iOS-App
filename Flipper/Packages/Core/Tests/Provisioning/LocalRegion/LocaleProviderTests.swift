import XCTest

@testable import Core

class LocaleProviderTests: XCTestCase {
    func testLocale() {
        let provider = LocaleRegionProvider(Locale(identifier: "pt_BR"))
        XCTAssertEqual(provider.regionCode, ISOCode("BR"))
    }

    func testUnknownLocale() {
        let provider = LocaleRegionProvider(Locale(identifier: ""))
        XCTAssertNil(provider.regionCode)
    }
}
