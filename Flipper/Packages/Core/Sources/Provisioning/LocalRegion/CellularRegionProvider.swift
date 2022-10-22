import CoreTelephony

// swiftlint:disable discouraged_optional_collection

public class CellularRegionProvider: RegionProvider {
    private let codesProvider: () -> [String]?

    public init() {
        self.codesProvider = {
            CTTelephonyNetworkInfo()
                .serviceSubscriberCellularProviders?
                .values
                .compactMap { $0.isoCountryCode }
        }
    }

    // @testable
    init(codesProvider: @escaping () -> [String]?) {
        self.codesProvider = codesProvider
    }

    public var regionCode: ISOCode? {
        guard
            let codes = codesProvider(),
            let first = codes.first,
            codes.allSatisfy({ $0 == first })
        else {
            return nil
        }
        return .init(first)
    }
}
