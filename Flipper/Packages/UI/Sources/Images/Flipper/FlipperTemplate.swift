import SwiftUI

struct FlipperTemplate: View {
    @Environment(\.flipperStyle) var style
    @Environment(\.flipperState) var state

    enum Style: String {
        case white
        case black
        case clear
    }

    enum State: String {
        case normal
        case disabled
    }

    var imageName: String {
        "FZ\(style.rawValue.capitalized)\(state.rawValue.capitalized)"
    }

    var body: some View {
        Image(imageName)
            .resizable()
            .scaledToFit()
    }
}
