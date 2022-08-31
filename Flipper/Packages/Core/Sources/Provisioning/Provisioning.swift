import Inject
import Analytics
import Peripheral
import Foundation

public class Provisioning {
    public static let location: Path = "/int/.region_data"

    @Inject private var analytics: Analytics

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
        reportProvisioning(geoIP: bundle.geoIP, provided: code)
        return .init(code: code, bands: bundle.bands[code])
    }
}

// MARK: Analytics

fileprivate extension Provisioning {
    func reportProvisioning(geoIP: ISOCode?, provided: ISOCode) {
        analytics.subghzProvisioning(
            sim1: cellurarRegionProvider.regionCode?.value ?? "",
            sim2: "",
            ip: geoIP?.value ?? "",
            system: localeRegionProvider.regionCode?.value ?? "",
            provided: provided.value,
            source: detectSource(geoIP: geoIP))
    }

    func detectSource(geoIP: ISOCode?) -> RegionSource {
        cellurarRegionProvider.regionCode != nil
            ? .sim
            : geoIP != nil
                ? .geoIP
                : localeRegionProvider.regionCode != nil
                    ? .locale
                    : .default
    }
}
