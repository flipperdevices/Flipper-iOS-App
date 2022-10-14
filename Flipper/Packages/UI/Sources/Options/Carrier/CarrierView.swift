import SwiftUI

struct CarrierView: View {
    @StateObject var viewModel: CarrierViewModel
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Locale Region: \(viewModel.regionCode)")
            ForEach(viewModel.carriers) { carrier in
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
                    presentationMode.wrappedValue.dismiss()
                }
                Title("I'm watching you")
            }
        }
    }
}
