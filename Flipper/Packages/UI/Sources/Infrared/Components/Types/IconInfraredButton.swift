import SwiftUI
import Core

struct IconInfraredButton: View {
    @Environment(\.layoutScaleFactor) private var scaleFactor

    let data: InfraredButtonData.Icon

    var body: some View {
        InfraredSquareButton {
            Image(data.image)
                .renderingMode(.template)
                .resizable()
                .frame(width: 24 * scaleFactor, height: 24 * scaleFactor)
                .foregroundColor(.white)
                .emulatable(keyID: data.keyId)
        }
    }
}

private extension InfraredButtonData.Icon {
    var image: String {
        let name = type
            .rawValue
            .split(separator: "_")
            .map { $0.capitalized }
            .joined()
        return "Infrared\(name)"
    }
}
