import SwiftUI

extension InfraredView {
    struct RemoteFoundBanner: View {
        var body: some View {
            Banner(
                image: "Done",
                title: "Remote Found",
                description: "This remote should match your device"
            )
        }
    }
}
