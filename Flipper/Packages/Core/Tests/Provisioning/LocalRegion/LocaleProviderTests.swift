import XCTest

@testable import Core

class LocaleProviderTests: XCTestCase {
    func testLocale() {
        Locale.with(localeIdentifier: "pt_BR") {
            let provider = LocaleRegionProvider()
            XCTAssertEqual(provider.regionCode, ISOCode("BR"))
        }
    }

    func testUnknownLocale() {
        Locale.with(localeIdentifier: nil) {
            let provider = LocaleRegionProvider()
            XCTAssertNil(provider.regionCode)
        }
    }
}
