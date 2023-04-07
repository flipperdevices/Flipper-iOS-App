import SwiftUI
import Peripheral

struct DeviceScreen: View {
    var uiImage: UIImage

    init(_ uiImage: UIImage) {
        self.uiImage = uiImage
    }

    var body: some View {
        Image("RemoteScreen")
            .resizable()
            .scaledToFit()
            .overlay(
                GeometryReader { proxy in
                    Image(uiImage: uiImage)
                        .resizable()
                        .interpolation(.none)
                        .aspectRatio(contentMode: .fit)
                        .padding(proxy.size.width * 0.04)
                }
            )
    }
}
