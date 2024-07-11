import SwiftUI
import Core

struct ChannelInfraredButton: View {
    @Environment(\.layoutScaleFactor) private var scaleFactor

    let data: ChannelButtonData

    var body: some View {
        InfraredSquareButton {
            VStack {
                Spacer()

                Text("+")
                    .font(.system(size: 20 * scaleFactor, weight: .medium))

                Spacer()

                Text("CH")
                    .font(.system(size: 14 * scaleFactor, weight: .medium))

                Spacer()

                Text("-")
                    .font(.system(size: 20 * scaleFactor, weight: .medium))

                Spacer()
            }
            .foregroundColor(.white)
        }
    }
}
