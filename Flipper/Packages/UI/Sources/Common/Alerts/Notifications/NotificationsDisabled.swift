import Core
import SwiftUI

struct NotificationsDisabledBanner: View {
    @Binding var isPresented: Bool
    @Environment(\.openURL) var openURL

    var body: some View {
        Banner(
            image: "Warning",
            title: "Notifications not enabled",
            description: "Allow notifications in settings"
        ) {
            Button("Go to Settings") {
                isPresented = false
                openURL(.notificationSettings)
            }
        }
    }
}
