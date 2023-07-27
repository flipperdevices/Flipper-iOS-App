import SwiftUI
import Peripheral

struct FlipperNoSDCardImage: View {
    var body: some View {
        ZStack {
            FlipperTemplate()
                .flipperState(.dead)

            Image("FZNoSDCardContent")
                .resizable()
                .scaledToFit()
        }
    }
}
