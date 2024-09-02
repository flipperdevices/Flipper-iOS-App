import SwiftUI
import Core

struct PowerInfraredButton: View {
    @Environment(\.layoutScaleFactor) private var scaleFactor
    @Environment(\.layoutState) private var layoutState

    let data: InfraredButtonData.Power

    private var powerColor: Color {
        switch layoutState {
        case .disabled: Color.red.opacity(0.2)
        default: Color.red
        }
    }

    var body: some View {
        InfraredSquareButton(forceColor: powerColor) {
            Image("InfraredPower")
                .renderingMode(.template)
                .resizable()
                .frame(width: 24 * scaleFactor, height: 24 * scaleFactor)
                .foregroundColor(.white)
                .onEmulate(keyID: data.keyId)
        }
    }
}
