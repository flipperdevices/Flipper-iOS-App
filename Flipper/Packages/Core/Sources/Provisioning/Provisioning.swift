import Peripheral
import Foundation

public class Provisioning {
    static let url: URL = "https://update.flipperzero.one/regions/api/v0/bundle"
    public static let location: Path = "/int/.region_data"

    public init() {}

    public struct Response: Decodable {
        let success: Database?
        let error: Error?
    }

    public struct Database: Decodable {
        let bands: [String: Band]
        let countries: [String: [String]]
        let country: String?
        let `default`: [String]
    }

    public struct Error: Decodable, Swift.Error {
        let code: Int
        let text: String

        static var unknown: Error { .init(code: 0, text: "unknown") }
    }

    public struct Region: Decodable {
        let country: String
        let bands: [Band]
    }

    public struct Band: Decodable {
        let dutyCycle: Int
        let end: Int
        let maxPower: Int
        let start: Int

        enum CodingKeys: String, CodingKey {
            case dutyCycle = "duty_cycle"
            case end
            case maxPower = "max_power"
            case start
        }
    }

    public static func generate() async throws -> [UInt8] {
        let database = try await downloadDatabase()
        let country = detectCountry(geoIP: database.getCountry())
        let region = database.getRegion(for: country)
        return try region.encode()
    }

    private static func downloadDatabase() async throws -> Database {
        let (data, _) = try await URLSession.shared.data(for: .init(url: url))
        let result = try JSONDecoder().decode(Response.self, from: data)
        guard let success = result.success else {
            throw result.error ?? .unknown
        }
        return success
    }

    private static func detectCountry(geoIP country: String?) -> String? {
        return RegionInfo.cellular ?? country ?? RegionInfo.locale
    }
}

fileprivate extension Provisioning.Database {
    func getCountry() -> String? {
        country?.count == 2 ? country : nil
    }

    func getRegion(for country: String?) -> Provisioning.Region {
        let bandNames = getBandNames(for: country)
        let bands = getBands(for: bandNames)
        return .init(country: country ?? "WW", bands: bands)
    }

    func getBandNames(for country: String?) -> [String] {
        guard let country = country else { return `default` }
        return countries[country] ?? `default`
    }

    func getBands(for bandNames: [String]) -> [Provisioning.Band] {
        bands
            .filter { bandNames.contains($0.key) }
            .map { $0.value }
    }
}

extension URL: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        guard let url = URL(string: value) else {
            fatalError("invalid url")
        }
        self = url
    }
}
