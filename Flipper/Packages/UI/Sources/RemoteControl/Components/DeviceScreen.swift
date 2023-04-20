import SwiftUI
import Peripheral

extension RemoteControlView {
    struct DeviceScreen<Content: View>: View {
        let content: () -> Content

        init(@ViewBuilder content: @escaping () -> Content) {
            self.content = content
        }

        var body: some View {
            Image("RemoteScreen")
                .resizable()
                .scaledToFit()
                .overlay(
                    GeometryReader { proxy in
                        content()
                            .padding(proxy.size.width * 0.04)
                    }
                )
        }
    }
}
