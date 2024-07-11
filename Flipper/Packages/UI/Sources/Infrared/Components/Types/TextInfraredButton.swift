import SwiftUI
import Core

struct TextInfraredButton: View {
    @Environment(\.layoutScaleFactor) private var scaleFactor

    let data: TextButtonData

    var body: some View {
        InfraredSquareButton {
            Text(data.text)
                .font(.system(size: 14 * scaleFactor, weight: .medium))
                .foregroundColor(.white)
        }
    }
}
