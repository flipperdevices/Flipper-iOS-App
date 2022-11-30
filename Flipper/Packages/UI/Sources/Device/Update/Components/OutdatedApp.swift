import SwiftUI

extension DeviceUpdateView {
    struct OutdatedAppView: View {
        var body: some View {
            VStack(spacing: 0) {
                Image("OutdatedApp")

                Text("Outdated mobile app version")
                    .font(.system(size: 14, weight: .medium))
                    .padding(.top, 12)

                Text(
                    "Update app to the latest version to " +
                    "install firmware on Flipper"
                )
                .font(.system(size: 14, weight: .medium))
                .multilineTextAlignment(.center)
                .foregroundColor(.black30)
                .padding(.top, 4)

                Button {
                    UIApplication.shared.open(.appStore)
                } label: {
                    Text("Go to App Store")
                        .font(.system(size: 16, weight: .medium))
                }
                .padding(.top, 12)
            }
            .padding(.horizontal, 24)
            .padding(.top, 38)
        }
    }
}
