import Core
import SwiftUI

struct AppsUpdateAvailableBanner: View {
    @Binding var isPresented: Bool

    @AppStorage(.selectedTab) var selectedTab: TabView.Tab = .device

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
                selectedTab = .hub
            }
        }
    }
}
