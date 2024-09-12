import SwiftUI
import Peripheral

struct ReaderConnecting: View {
    let flipperColor: FlipperColor

    var body: some View {
        VStack(spacing: 18) {
            Text("Connecting Flipper...")
                .font(.system(size: 18, weight: .bold))

            FlipperConnectingImage()
                .flipperColor(flipperColor)
                .padding(.leading, 10)
                .padding(.trailing, 22)
        }
    }
}
