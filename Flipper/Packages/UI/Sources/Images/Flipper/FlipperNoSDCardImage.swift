import SwiftUI
import Peripheral

struct FlipperNoSDCardImage: View {
    var body: some View {
        ZStack {
            FlipperTemplate()
                .flipperState(.disabled)

            Image("FZNoSDCardContent")
                .resizable()
                .scaledToFit()
        }
    }
}
