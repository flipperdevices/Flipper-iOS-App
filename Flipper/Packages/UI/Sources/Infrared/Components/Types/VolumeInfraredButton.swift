import SwiftUI
import Core

struct VolumeInfraredButton: View {
    @Environment(\.layoutScaleFactor) private var scaleFactor

    let data: InfraredButtonData.Volume

    var body: some View {
        InfraredSquareButton {
            VStack {
                Spacer()

                Text("+")
                    .font(.system(size: 20 * scaleFactor, weight: .medium))
                    .onEmulate(keyID: data.addKeyId)

                Spacer()

                Text("VOL")
                    .font(.system(size: 14 * scaleFactor, weight: .medium))

                Spacer()

                Text("-")
                    .font(.system(size: 20 * scaleFactor, weight: .medium))
                    .onEmulate(keyID: data.reduceKeyId)

                Spacer()
            }
            .foregroundColor(.white)
        }
    }
}
