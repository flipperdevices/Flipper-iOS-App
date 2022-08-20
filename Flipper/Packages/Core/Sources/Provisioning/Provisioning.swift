import Peripheral
import Foundation

public class Provisioning {
    public static let location: Path = "/int/.region_data"

    private let cellurarRegionProvider: RegionProvider
    private let localeRegionProvider: RegionProvider
    private let regionsBundleAPI: RegionsBundleAPI

    public struct Region: Equatable {
        let code: ISOCode
        let bands: [Band]
    }

    public struct Band: Equatable {
        let start: Int
        let end: Int
        let dutyCycle: Int
        let maxPower: Int
    }

    public struct Error: Swift.Error {
        let code: Int
        let message: String
    }

    public init() {
        self.cellurarRegionProvider = CellurarRegionProvider()
        self.localeRegionProvider = LocaleRegionProvider()
        self.regionsBundleAPI = RegionsBundleAPIv0()
    }

    // @testable
    init(
        cellurarRegionProvider: RegionProvider,
        localeRegionProvider: RegionProvider,
        regionsBundleAPI: RegionsBundleAPI
    ) {
        self.cellurarRegionProvider = cellurarRegionProvider
        self.localeRegionProvider = localeRegionProvider
        self.regionsBundleAPI = regionsBundleAPI
    }

    public func provideRegion() async throws -> Region {
        let bundle = try await regionsBundleAPI.get()
        let code = cellurarRegionProvider.regionCode
            ?? bundle.geoIP
            ?? localeRegionProvider.regionCode
            ?? .default
        let bands = bundle.bands[code]
        return .init(code: code, bands: bands)
    }
}
