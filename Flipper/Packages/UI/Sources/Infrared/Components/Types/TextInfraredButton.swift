import SwiftUI
import Core

struct TextInfraredButton: View {
    @Environment(\.layoutScaleFactor) private var scaleFactor
    @Environment(\.emulateAction) private var action

    let data: InfraredButtonData.Text

    var body: some View {
        InfraredSquareButton {
            Text(data.text)
                .font(.system(size: 14 * scaleFactor, weight: .medium))
                .multilineTextAlignment(.center)
                .lineLimit(1)
                .foregroundColor(.white)
                .padding(2)
                .onTapGesture {
                    action(data.keyId)
                }
        }
    }
}
