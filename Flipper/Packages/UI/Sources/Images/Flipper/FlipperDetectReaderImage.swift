import SwiftUI
import Peripheral

struct FlipperDetectReaderImage: View {
    var body: some View {
        ZStack {
            FlipperTemplate()

            Image("FZDetectReaderContent")
                .resizable()
                .scaledToFit()
        }
    }
}
