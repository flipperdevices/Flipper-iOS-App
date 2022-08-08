import CoreTelephony

enum RegionInfo {
    static var cellular: String? {
        guard let providers = CTTelephonyNetworkInfo()
            .serviceSubscriberCellularProviders
        else {
            return nil
        }

        let codes = providers
            .values
            .compactMap { $0.isoCountryCode?.uppercased() }

        switch codes.count {
        case 1: return codes[0]
        case 2... where codes.allEqual(): return codes[0]
        default: return nil
        }
    }

    static var locale: String? {
        Locale
            .current
            .regionCode?
            .uppercased()
    }
}

fileprivate extension Array where Element: Equatable {
    func allEqual() -> Bool {
        assert(!isEmpty)
        return allSatisfy { $0 == self[0] }
    }
}
