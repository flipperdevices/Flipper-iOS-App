import SwiftUI
import Peripheral

struct FlipperUpdatingImage: View {
    var body: some View {
        ZStack {
            FlipperTemplate()

            Image("FZUpdatingContent")
                .resizable()
                .scaledToFit()
        }
    }
}
