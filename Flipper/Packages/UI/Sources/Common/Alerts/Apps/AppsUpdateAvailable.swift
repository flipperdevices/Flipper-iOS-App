import Core
import SwiftUI

struct AppsUpdateAvailableBanner: View {
    @Binding var isPresented: Bool

    @Environment(\.notifications) private var notifications

    var image: Image {
        Image("AppsUpdate")
            .renderingMode(.template)
    }

    var body: some View {
        Banner(
            image: image,
            title: "Update Apps",
            description: "Apps installed on your Flipper require updates"
        ) {
            Button("Go to Update") {
                isPresented = false
                notifications.apps.showApps = true
            }
        }
    }
}
