import SwiftUI
import Core

struct TextInfraredButton: View {
    @Environment(\.layoutScaleFactor) private var scaleFactor

    let data: InfraredButtonData.Text

    var body: some View {
        InfraredSquareButton {
            Text(data.text)
                .font(.system(size: 14 * scaleFactor, weight: .medium))
                .multilineTextAlignment(.center)
                .lineLimit(1)
                .foregroundColor(.white)
                .padding(2)
                .onEmulate(keyID: data.keyId)
        }
    }
}
