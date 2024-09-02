import SwiftUI
import Core

struct VolumeInfraredButton: View {
    @Environment(\.layoutScaleFactor) private var scaleFactor

    let data: InfraredButtonData.Volume

    var body: some View {
        InfraredSquareButton {
            VStack {
                Spacer()

                Image("InfraredPlus")
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 24 * scaleFactor, height: 24 * scaleFactor)
                    .onEmulate(keyID: data.addKeyId)

                Spacer()

                Text("VOL")
                    .font(.system(size: 14 * scaleFactor, weight: .medium))

                Spacer()

                Image("InfraredMinus")
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 24 * scaleFactor, height: 24 * scaleFactor)
                    .onEmulate(keyID: data.reduceKeyId)

                Spacer()
            }
            .foregroundColor(.white)
        }
    }
}
