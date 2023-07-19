import SwiftUI
import Peripheral

struct FlipperFlashingIssueImage: View {
    var body: some View {
        ZStack {
            FlipperTemplate()
                .flipperState(.dead)

            Image("FZFlashingIssueContent")
                .resizable()
                .scaledToFit()
        }
    }
}
