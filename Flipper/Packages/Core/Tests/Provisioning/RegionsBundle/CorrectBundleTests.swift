import XCTest

@testable import Core

// swiftlint:disable force_unwrapping

class CorrectBundleTests: XCTestCase {
    func testBundle() async throws {
        let provider = RegionsBundleAPIv0 {
            correctV0BundleJSON.data(using: .utf8)!
        }
        let bundle = try await provider.get()
        XCTAssertEqual(bundle.geoIP, .init("US"))

        XCTAssertEqual(bundle.bands[.init("AD")!], [
            .init(
                start: 433050000,
                end: 434790000,
                dutyCycle: 50,
                maxPower: 12),
            .init(
                start: 868150000,
                end: 868550000,
                dutyCycle: 50,
                maxPower: 12)
        ])

        XCTAssertEqual(bundle.bands[.init("AE")!], [
            .init(
                start: 420000000,
                end: 440000000,
                dutyCycle: 50,
                maxPower: -6)
        ])

        XCTAssertEqual(bundle.bands[.init("US")!], [
            .init(
                start: 304100000,
                end: 321950000,
                dutyCycle: 50,
                maxPower: 12),
            .init(
                start: 433050000,
                end: 434790000,
                dutyCycle: 50,
                maxPower: 12),
            .init(
                start: 915000000,
                end: 928000000,
                dutyCycle: 50,
                maxPower: 12)
        ])

        XCTAssertEqual(bundle.bands[.default], [
            .init(
                start: 312000000,
                end: 315250000,
                dutyCycle: 50,
                maxPower: 12),
            .init(
                start: 920500000,
                end: 923500000,
                dutyCycle: 50,
                maxPower: 12)
        ])
    }
}

private var correctV0BundleJSON = """
    {
        "success":
        {
            "bands":
            {
                "FS_AE_420":
                {
                    "duty_cycle": 50,
                    "end": 440000000,
                    "max_power": -6,
                    "start": 420000000
                },
                "F_EU_433":
                {
                    "duty_cycle": 50,
                    "end": 434790000,
                    "max_power": 12,
                    "start": 433050000
                },
                "F_EU_868":
                {
                    "duty_cycle": 50,
                    "end": 868550000,
                    "max_power": 12,
                    "start": 868150000
                },
                "F_JP_312":
                {
                    "duty_cycle": 50,
                    "end": 315250000,
                    "max_power": 12,
                    "start": 312000000
                },
                "F_JP_920":
                {
                    "duty_cycle": 50,
                    "end": 923500000,
                    "max_power": 12,
                    "start": 920500000
                },
                "F_US_CA_304":
                {
                    "duty_cycle": 50,
                    "end": 321950000,
                    "max_power": 12,
                    "start": 304100000
                },
                "F_US_CA_AU_NZ_433":
                {
                    "duty_cycle": 50,
                    "end": 434790000,
                    "max_power": 12,
                    "start": 433050000
                },
                "F_US_CA_AU_NZ_915":
                {
                    "duty_cycle": 50,
                    "end": 928000000,
                    "max_power": 12,
                    "start": 915000000
                }
            },
            "countries":
            {
                "AD":
                [
                    "F_EU_433",
                    "F_EU_868"
                ],
                "AE":
                [
                    "FS_AE_420"
                ],
                "US":
                [
                    "F_US_CA_304",
                    "F_US_CA_AU_NZ_433",
                    "F_US_CA_AU_NZ_915"
                ]
            },
            "country": "US",
            "default":
            [
                "F_JP_312",
                "F_JP_920"
            ]
        }
    }
    """
