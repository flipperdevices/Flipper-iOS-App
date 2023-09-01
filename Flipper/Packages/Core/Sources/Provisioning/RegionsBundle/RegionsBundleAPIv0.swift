import Foundation

public class RegionsBundleAPIv0: RegionsBundleAPI {
    private let dataProvider: () async throws -> Data

    public struct Response: Decodable {
        let success: Bundle?
        let error: Error?
    }

    struct Bundle: Decodable {
        let country: String?
        let countries: [String: [String]]
        let bands: [String: Band]
        let `default`: [String]

        struct Band: Decodable {
            let start: Int
            let end: Int
            let dutyCycle: Int
            let maxPower: Int

            enum CodingKeys: String, CodingKey {
                case start
                case end
                case dutyCycle = "duty_cycle"
                case maxPower = "max_power"
            }
        }
    }

    public struct Error: Decodable, Swift.Error {
        let code: Int
        let text: String

        static var unknown: Error { .init(code: 0, text: "unknown") }
    }

    public init() {
        dataProvider = {
            try await URLSession.shared.data(
                from: "https://update.flipperzero.one/regions/api/v0/bundle"
            ).0
        }
    }

    // @testable
    init(dataProvider: @escaping () async throws -> String) {
        self.dataProvider = {
            try await .init(dataProvider().utf8)
        }
    }

    public func get() async throws -> RegionsBundle {
        let data = try await dataProvider()
        let result = try JSONDecoder().decode(Response.self, from: data)
        guard let success = result.success else {
            throw Provisioning.Error(result.error ?? .unknown)
        }
        return .init(success)
    }
}

// MARK: Transform V0.Bundle to RegionsBundle

extension RegionsBundle {
    init(_ source: RegionsBundleAPIv0.Bundle) {
        self.geoIP = .init(source.country ?? "unknown")
        self.bands = .init(source)
    }
}

extension RegionBands {
    init(_ source: RegionsBundleAPIv0.Bundle) {
        var bands: [ISOCode: [Provisioning.Band]] = [:]
        for (countryCode, bandNames) in source.countries {
            guard let code = ISOCode(countryCode) else {
                continue
            }
            bands[code] = .init(source.getBands(for: bandNames))
        }
        bands[.default] = .init(source.getBands(for: source.default))
        self.values = bands
    }
}

fileprivate extension RegionsBundleAPIv0.Bundle {
    func getBands(for bandNames: [String]) -> [Band] {
        bands
            .filter { bandNames.contains($0.key) }
            .map { $0.value }
            .sorted { $0.start < $1.start }
    }
}

// MARK: Transform V0.Band to Provisioning.Band

fileprivate extension Array where Element == Provisioning.Band {
    init(_ source: [RegionsBundleAPIv0.Bundle.Band]) {
        self = source.map { .init($0) }
    }
}

fileprivate extension Provisioning.Band {
    init(_ source: RegionsBundleAPIv0.Bundle.Band) {
        self.start = source.start
        self.end = source.end
        self.dutyCycle = source.dutyCycle
        self.maxPower = source.maxPower
    }
}

// MARK: Transform V0.Error to Provisioning.Error

fileprivate extension Provisioning.Error {
    init(_ source: RegionsBundleAPIv0.Error) {
        self.code = source.code
        self.message = source.text
    }
}
