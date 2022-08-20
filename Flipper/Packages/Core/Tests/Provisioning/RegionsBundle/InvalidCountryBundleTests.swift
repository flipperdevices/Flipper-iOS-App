import XCTest

@testable import Core

// swiftlint:disable force_unwrapping

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
            """.data(using: .utf8)!
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
            """.data(using: .utf8)!
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
            """.data(using: .utf8)!
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
            """.data(using: .utf8)!
        }
        let bundle = try await provider.get()
        XCTAssertNil(bundle.geoIP)
    }
}
