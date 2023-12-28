import Core
import SwiftUI

struct NotificationsEnabledBanner: View {
    @Binding var isPresented: Bool

    var body: some View {
        Banner(
            image: "Done",
            title: "Notifications enabled",
            description: "You will be notified about firmware releases"
        )
    }
}
