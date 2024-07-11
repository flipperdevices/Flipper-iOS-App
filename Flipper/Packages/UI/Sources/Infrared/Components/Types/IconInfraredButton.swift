import SwiftUI
import Core

struct IconInfraredButton: View {
    @Environment(\.layoutScaleFactor) private var scaleFactor

    let data: IconButtonData

    var body: some View {
        InfraredSquareButton {
            Image(data.icon.image)
                .renderingMode(.template)
                .resizable()
                .frame(width: 24 * scaleFactor, height: 24 * scaleFactor)
                .foregroundColor(data.icon.color)
        }
    }
}

private extension IconButtonData.IconType {
    var image: String {
        return switch self {
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

    var color: Color {
        switch self {
        case .power: .red
        default: .white
        }
    }
}
