import SwiftUI
import Peripheral

struct FlipperFlashingIssueImage: View {
    var body: some View {
        ZStack {
            FlipperTemplate()
                .flipperState(.disabled)

            Image("FZFlashingIssueContent")
                .resizable()
                .scaledToFit()
        }
    }
}
