import SwiftUI
import Peripheral

struct FlipperDeadImage: View {
    var body: some View {
        ZStack {
            FlipperTemplate()
                .flipperState(.disabled)

            Image("FZDeadContent")
                .resizable()
                .scaledToFit()
        }
    }
}
