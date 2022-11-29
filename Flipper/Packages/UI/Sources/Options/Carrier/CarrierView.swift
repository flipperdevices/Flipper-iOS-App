import SwiftUI
import CoreTelephony

struct CarrierView: View {
    @Environment(\.dismiss) var dismiss

    var regionCode: String {
        Locale.current.regionCode ?? "unknown"
    }

    var carriers: [Carrier] {
        (CTTelephonyNetworkInfo().serviceSubscriberCellularProviders ?? [:])
            .map {
                .init(
                    id: $0.key,
                    name: $0.value.carrierName ?? "unknown",
                    countryCode: $0.value.mobileCountryCode ?? "unknown",
                    networkCode: $0.value.mobileNetworkCode ?? "unknown",
                    isoCountryCode: $0.value.isoCountryCode ?? "unknown",
                    allowsVOIP: $0.value.allowsVOIP ? "yes" : "no")
            }
    }

    struct Carrier: Identifiable {
        let id: String
        let name: String
        let countryCode: String
        let networkCode: String
        let isoCountryCode: String
        let allowsVOIP: String
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Locale Region: \(regionCode)")
            ForEach(carriers) { carrier in
                VStack(alignment: .leading) {
                    Text("ID: \(carrier.id)")
                    Text("Carrier name: \(carrier.name)")
                    Text("Mobile Country Code: \(carrier.countryCode)")
                    Text("Mobile Network Code: \(carrier.networkCode)")
                    Text("ISO Country Code: \(carrier.isoCountryCode)")
                    Text("Allows VOIP: \(carrier.allowsVOIP)")
                }
            }
        }
        .padding(14)
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            LeadingToolbarItems {
                BackButton {
                    dismiss()
                }
                Title("I'm watching you")
            }
        }
    }
}

extension String {
    var localizedCountry: String {
        (Locale.current as NSLocale)
            .displayName(forKey: .countryCode, value: self) ?? "unknown"
    }
}
