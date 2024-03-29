import SwiftUI

extension DeviceUpdateCard {
    struct CardStateInProgress: View {
        var body: some View {
            Image("UpdateStarted")
                .padding(.top, 12)
                .padding(.horizontal, 12)

            Text("Update started...")
                .padding(.top, 8)

            VStack {
                Text(
                    "Flipper is updating in offline mode. " +
                    "Check the device screen for info and wait for " +
                    "reconnect."
                )
                .font(.system(size: 14, weight: .medium))
                .multilineTextAlignment(.center)
                .foregroundColor(.black30)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
        }
    }
}
