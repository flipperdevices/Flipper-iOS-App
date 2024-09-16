import SwiftUI
import Core

struct ShutterInfraredButton: View {
    @Environment(\.layoutScaleFactor) private var scaleFactor
    @Environment(\.layoutState) private var state
    @Environment(\.colorScheme) private var colorScheme

    let data: InfraredButtonData.Shutter

    private var innerCircleColor: Color {
        switch colorScheme {
        case .light: state == .disabled ? Color.black12 : Color.black40
        default: state == .disabled ? Color.black80 : Color.black60
        }
    }

    var body: some View {
        InfraredSquareButton {
            Circle()
                .fill(innerCircleColor)
                .padding(14 * scaleFactor)
                .opacity(state == .emulating ? 0 : 1)

            Image("InfraredShutter")
                .renderingMode(.template)
                .resizable()
                .frame(width: 48 * scaleFactor, height: 48 * scaleFactor)
                .foregroundColor(.white)
                .emulatable(keyID: data.keyId)
        }
        .cornerRadius(.infinity)
    }
}

#Preview {
    ShutterInfraredButton(
        data: .init(
            keyId: .unknown
        )
    )
    .frame(width: 300, height: 300)
}
