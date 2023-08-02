import SwiftUI
import Peripheral

struct FlipperDeadImage: View {
    var body: some View {
        ZStack {
            FlipperTemplate()
                .flipperState(.dead)

            Image("FZDeadContent")
                .resizable()
                .scaledToFit()
        }
    }
}
