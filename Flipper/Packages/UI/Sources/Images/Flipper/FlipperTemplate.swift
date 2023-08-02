import SwiftUI

struct FlipperTemplate: View {
    @Environment(\.flipperStyle) var style
    @Environment(\.flipperState) var state

    enum Style {
        case white
        case black
    }

    enum State {
        case normal
        case dead
    }

    var flipperColor: Color {
        switch style {
        case .white: return .white
        case .black: return .blackFlipper
        }
    }

    var controlsColor: Color {
        switch state {
        case .normal: return .a1
        case .dead: return .black30
        }
    }

    var body: some View {
        ZStack {
            Image("FZBackground")
                .renderingMode(.template)
                .resizable()
                .foregroundColor(flipperColor)

            Group {
                Image("FZLogo")
                    .renderingMode(.template)
                    .resizable()

                Image("FZControlsBackground")
                    .renderingMode(.template)
                    .resizable()

                Image("FZScreen")
                    .renderingMode(.template)
                    .resizable()
            }
            .foregroundColor(controlsColor)

            Image("FZOutline")
                .resizable()
        }
        .scaledToFit()
    }
}

private extension Color {
    static var blackFlipper: Color {
        .init(red: 79 / 255, green: 74 / 255, blue: 84 / 255)
    }
}
