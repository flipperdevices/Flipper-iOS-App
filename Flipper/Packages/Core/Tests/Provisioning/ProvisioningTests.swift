import XCTest

@testable import Core

class ProvisioningTests: XCTestCase {
    class TestRegion: RegionProvider {
        let regionCode: ISOCode?

        init(_ regionCode: ISOCode?) {
            self.regionCode = regionCode
        }
    }

    class TestBundle: RegionsBundleAPI {
        var bundle: RegionsBundle

        init(_ bundle: RegionsBundle) { self.bundle = bundle }

        func get() async throws -> RegionsBundle {
            bundle
        }
    }

    func testSim() async throws {
        let provisioning = Provisioning(
            cellurarRegionProvider: TestRegion(.ae),
            localeRegionProvider: TestRegion(.ad),
            regionsBundleAPI: TestBundle(.init(geoIP: .us, bands: .testBands)))

        let region = try await provisioning.provideRegion()

        XCTAssertEqual(region.code, .ae)
        XCTAssertEqual(region.bands, RegionBands.testBands[.ae])
    }

    func testGeoIP() async throws {
        let provisioning = Provisioning(
            cellurarRegionProvider: TestRegion(nil),
            localeRegionProvider: TestRegion(.ad),
            regionsBundleAPI: TestBundle(.init(geoIP: .us, bands: .testBands)))

        let region = try await provisioning.provideRegion()

        XCTAssertEqual(region.code, .us)
        XCTAssertEqual(region.bands, RegionBands.testBands[.us])
    }

    func testLocale() async throws {
        let provisioning = Provisioning(
            cellurarRegionProvider: TestRegion(nil),
            localeRegionProvider: TestRegion(.ad),
            regionsBundleAPI: TestBundle(.init(geoIP: nil, bands: .testBands)))

        let region = try await provisioning.provideRegion()

        XCTAssertEqual(region.code, .ad)
        XCTAssertEqual(region.bands, RegionBands.testBands[.ad])
    }

    func testDefault() async throws {
        let provisioning = Provisioning(
            cellurarRegionProvider: TestRegion(nil),
            localeRegionProvider: TestRegion(nil),
            regionsBundleAPI: TestBundle(.init(geoIP: nil, bands: .testBands)))

        let region = try await provisioning.provideRegion()

        XCTAssertEqual(region.code, .default)
        XCTAssertEqual(region.bands, RegionBands.testBands[.default])
    }
}

// swiftlint:disable force_unwrapping

extension ISOCode {
    static var ad: ISOCode { .init("AD")! }
    static var ae: ISOCode { .init("AE")! }
    static var us: ISOCode { .init("US")! }
}

extension RegionBands {
    static var testBands: Self {
        .init(values: [
            .ae: [.init(start: 1, end: 1, dutyCycle: 1, maxPower: 1)],
            .ad: [.init(start: 2, end: 2, dutyCycle: 2, maxPower: 2)],
            .us: [.init(start: 3, end: 3, dutyCycle: 3, maxPower: 3)],
            .default: [.init(start: 42, end: 42, dutyCycle: 42, maxPower: 42)]
        ])
    }
}
