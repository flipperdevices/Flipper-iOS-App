import XCTest

@testable import Core

class RegionEncodeTests: XCTestCase {
    func testDefaultRegion() throws {
        let region = Provisioning.Region(
            code: .default,
            bands: [
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

        let bytes = try region.encode()

        XCTAssertEqual(bytes, [
            0x0a, 0x02, 0x57, 0x57, 0x12, 0x10, 0x08, 0x80,
            0xfc, 0xe2, 0x94, 0x01, 0x10, 0xd0, 0xaa, 0xa9,
            0x96, 0x01, 0x18, 0x0c, 0x20, 0x32, 0x12, 0x10,
            0x08, 0xa0, 0xee, 0xf6, 0xb6, 0x03, 0x10, 0xe0,
            0xfb, 0xad, 0xb8, 0x03, 0x18, 0x0c, 0x20, 0x32
        ])
    }
}
