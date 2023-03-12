import SwiftUI
import Peripheral

struct DeviceScreen: View {
    var pixels: [Bool]

    var width: Int { 128 }
    var height: Int { 64 }

    var colorPixels: [PixelColor] {
        self.pixels.map { $0 ? .black : .orange }
    }

    var uiImage: UIImage {
        UIImage(pixels: colorPixels, width: width, height: height) ?? .init()
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
                    .padding(12)
            )
    }
}
