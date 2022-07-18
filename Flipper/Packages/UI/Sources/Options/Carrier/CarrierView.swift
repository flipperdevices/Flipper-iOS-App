import SwiftUI

struct CarrierView: View {
    @StateObject var viewModel: CarrierViewModel
    @Environment(\.dismiss) var dismiss

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
            ToolbarItem(placement: .navigationBarLeading) {
                BackButton {
                    dismiss()
                }
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Text("I'm watching you")
                    .font(.system(size: 20, weight: .bold))
            }
        }
    }
}
