import SwiftUI
import Core

struct IconInfraredButton: View {
    @Environment(\.layoutScaleFactor) private var scaleFactor

    let data: InfraredButtonData.Icon

    var body: some View {
        InfraredSquareButton(color: data.color) {
            Image(data.image)
                .renderingMode(.template)
                .resizable()
                .frame(width: 24 * scaleFactor, height: 24 * scaleFactor)
                .foregroundColor(.white)
                .onEmulate(keyID: data.keyId)
        }
    }
}

private extension InfraredButtonData.Icon {
    var image: String {
        return switch self.type {
            case .back: "InfraredBack"
            case .home: "InfraredHome"
            case .info: "InfraredInfo"
            case .more: "InfraredMore"
            case .mute: "InfraredMute"
            case .power: "InfraredPower"
            case .cool: "InfraredCool"
            case .heat: "InfraredHeat"
            }
    }

    var color: Color? {
        switch self.type {
        case .power: .red
        default: nil
        }
    }
}
