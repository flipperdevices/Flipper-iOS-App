import SwiftUI
import Peripheral

extension RemoteControlView {
    struct DeviceScreen: View {
        var uiImage: UIImage?

        init(_ uiImage: UIImage?) {
            self.uiImage = uiImage
        }

        var body: some View {
            Image("RemoteScreen")
                .resizable()
                .scaledToFit()
                .overlay(
                    GeometryReader { proxy in
                        if let uiImage = uiImage {
                            Image(uiImage: uiImage)
                                .resizable()
                                .interpolation(.none)
                                .aspectRatio(contentMode: .fit)
                                .padding(proxy.size.width * 0.04)
                        } else {
                            AnimatedPlaceholder()
                                .padding(proxy.size.width * 0.04)
                        }
                    }
                )
        }
    }
}
