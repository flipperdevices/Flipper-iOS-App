import CoreTelephony

@MainActor
class CarrierViewModel: ObservableObject {
    let carriers: [Carrier]
    var regionCode: String {
        Locale.current.regionCode ?? "unkwnown"
    }

    struct Carrier: Identifiable {
        let id: String
        let name: String
        let countryCode: String
        let networkCode: String
        let isoCountryCode: String
        let allowsVOIP: String
    }

    init() {
        var carriers: [Carrier] = []
        CTTelephonyNetworkInfo().serviceSubscriberCellularProviders?.forEach {
            let carrier = $0.value
            carriers.append(.init(
                id: $0.key,
                name: carrier.carrierName ?? "unknown",
                countryCode: carrier.mobileCountryCode ?? "unknown",
                networkCode: carrier.mobileNetworkCode ?? "unknown",
                isoCountryCode: carrier.isoCountryCode ?? "unknown",
                allowsVOIP: carrier.allowsVOIP ? "yes" : "no"))
        }
        self.carriers = carriers
    }
}

extension String {
    var localizedCountry: String {
        (Locale.current as NSLocale)
            .displayName(forKey: .countryCode, value: self) ?? "unknown"
    }
}
