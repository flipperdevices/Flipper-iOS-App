import SwiftUI
import Core

struct ChannelInfraredButton: View {
    @Environment(\.layoutScaleFactor) private var scaleFactor

    let data: InfraredButtonData.Channel

    var body: some View {
        InfraredSquareButton {
            VStack {
                Spacer()

                Image("InfraredPlus")
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 24 * scaleFactor, height: 24 * scaleFactor)
                    .emulatable(keyID: data.addKeyId)

                Spacer()

                Text("CH")
                    .font(.system(size: 14 * scaleFactor, weight: .medium))

                Spacer()

                Image("InfraredMinus")
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 24 * scaleFactor, height: 24 * scaleFactor)
                    .emulatable(keyID: data.reduceKeyId)

                Spacer()
            }
            .foregroundColor(.white)
        }
    }
}
