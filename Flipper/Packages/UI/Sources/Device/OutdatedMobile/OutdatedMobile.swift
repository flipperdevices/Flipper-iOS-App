import SwiftUI

struct OutdatedMobileCard: View {
    @Environment(\.openURL) private var openURL

    var body: some View {
        Card {
            VStack(spacing: 0) {
                Image("OutdatedMobile")

                Text("Outdated mobile app version")
                    .font(.system(size: 14, weight: .medium))
                    .multilineTextAlignment(.center)
                    .padding(.top, 4)

                Text(
                    "Update the app to the latest version to connect to Flipper"
                )
                .font(.system(size: 14, weight: .medium))
                .multilineTextAlignment(.center)
                .foregroundColor(.black40)
                .padding(.top, 2)

                Button {
                    openURL(.appStore)
                } label: {
                    Text("Go to App Store")
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.a2)
                .padding(.top, 8)
            }
            .frame(maxWidth: .infinity)
            .padding(12)
        }
    }
}
