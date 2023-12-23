import SwiftUI
import Peripheral

struct FlipperConnectingImage: View {
    var body: some View {
        ZStack {
            FlipperTemplate()
                .flipperState(.disabled)

            // TODO: Add animated placeholder
            // AnimatedPlaceholder()
        }
    }
}
