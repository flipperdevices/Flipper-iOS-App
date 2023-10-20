import CoreTelephony

public class CellularRegionProvider: RegionProvider {
    private let codesProvider: () -> [String]?

    public init() {
        self.codesProvider = {
            #if canImport(UIKit)
            CTTelephonyNetworkInfo()
                .serviceSubscriberCellularProviders?
                .values
                .compactMap { $0.isoCountryCode }
            #else
            []
            #endif
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
