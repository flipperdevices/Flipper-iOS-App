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
                Image(uiImage: uiImage)
                    .resizable()
                    .interpolation(.none)
                    .aspectRatio(contentMode: .fit)
                    .padding(14)
            )
    }
}
