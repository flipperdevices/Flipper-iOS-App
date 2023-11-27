import Core
import SwiftUI

struct NotificationsDisabledAlert: View {
    @Binding var isPresented: Bool

    @Environment(\.openURL) var openURL

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 4) {
                Image("NotificationsAlert")

                Text("Notifications Not Enabled")
                    .font(.system(size: 14, weight: .bold))

                Text("You can enable them in app Settings")
                    .font(.system(size: 14, weight: .medium))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black40)
                    .padding(.horizontal, 12)
            }
            .padding(.top, 25)

            Button {
                openURL(.notificationSettings)
                isPresented = false
            } label: {
                Text("Go to Settings")
                    .roundedButtonStyle(maxWidth: .infinity)
            }
        }
    }
}
