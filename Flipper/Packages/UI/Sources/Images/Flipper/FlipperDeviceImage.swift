import SwiftUI
import Peripheral

struct FlipperDeviceImage: View {
    var body: some View {
        ZStack {
            FlipperTemplate()

            Image("FZDeviceContent")
                .resizable()
                .scaledToFit()
        }
    }
}
