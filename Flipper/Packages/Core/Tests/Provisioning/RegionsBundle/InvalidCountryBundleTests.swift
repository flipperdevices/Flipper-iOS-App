import XCTest

@testable import Core

class InvalidCountryBundleTests: XCTestCase {
    func testUnknownCountry() async throws {
        let provider = RegionsBundleAPIv0 {
            """
            {
                "success":
                {
                    "bands": {},
                    "countries": {},
                    "country": "unknown",
                    "default": []
                }
            }
            """
        }
        let bundle = try await provider.get()
        XCTAssertNil(bundle.geoIP)
    }

    func testEmptyCountry() async throws {
        let provider = RegionsBundleAPIv0 {
            """
            {
                "success":
                {
                    "bands": {},
                    "countries": {},
                    "country": "",
                    "default": []
                }
            }
            """
        }
        let bundle = try await provider.get()
        XCTAssertNil(bundle.geoIP)
    }

    func testNullCountry() async throws {
        let provider = RegionsBundleAPIv0 {
            """
            {
                "success":
                {
                    "bands": {},
                    "countries": {},
                    "country": null,
                    "default": []
                }
            }
            """
        }
        let bundle = try await provider.get()
        XCTAssertNil(bundle.geoIP)
    }

    func testMissingCountry() async throws {
        let provider = RegionsBundleAPIv0 {
            """
            {
                "success":
                {
                    "bands": {},
                    "countries": {},
                    "default": []
                }
            }
            """
        }
        let bundle = try await provider.get()
        XCTAssertNil(bundle.geoIP)
    }
}
