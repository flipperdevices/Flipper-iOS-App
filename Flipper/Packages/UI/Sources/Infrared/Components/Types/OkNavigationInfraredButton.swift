import SwiftUI
import Core

struct OkNavigationInfraredButton: View {
    @Environment(\.layoutScaleFactor) private var scaleFactor
    @Environment(\.layoutState) private var layoutState
    @Environment(\.colorScheme) private var colorScheme

    let data: InfraredButtonData.OkNavigation

    var body: some View {
        GeometryReader { proxy in
            InfraredSquareButton {
                Grid {
                    GridRow {
                        Spacer()
                        buttonNavigation()
                            .emulatable(keyID: data.leftKeyId)
                        Spacer()
                    }
                    GridRow {
                        buttonNavigation()
                            .rotationEffect(.degrees(-90))
                            .emulatable(keyID: data.upKeyId)
                        buttonOk(layoutState)
                            .frame(
                                width: proxy.size.width / 3,
                                height: proxy.size.height / 3
                            )
                            .emulatable(keyID: data.okKeyId)
                        buttonNavigation()
                            .rotationEffect(.degrees(90))
                            .emulatable(keyID: data.downKeyId)

                    }
                    GridRow {
                        Spacer()
                        buttonNavigation()
                            .rotationEffect(.degrees(180))
                            .emulatable(keyID: data.rightKeyId)
                        Spacer()
                    }
                }
            }
            .cornerRadius(.infinity)
        }
    }

    @ViewBuilder
    private func buttonNavigation() -> some View {
        Image("InfraredNavigation")
            .resizable()
            .frame(
                width: 24 * scaleFactor,
                height: 24 * scaleFactor)
    }

    @ViewBuilder
    private func buttonOk(_ state: InfraredLayoutState) -> some View {

        let innerCircleColor = switch colorScheme {
        case .light: state == .disabled ? Color.black12 : Color.black40
        default: state == .disabled ? Color.black80 : Color.black60
        }

        ZStack {
            Group {
                Circle()
                    .fill(innerCircleColor)

                Circle()
                    .strokeBorder(Color.background, lineWidth: 4 * scaleFactor)
            }
            .opacity(state == .emulating ? 0 : 1)

            Text("OK")
                .font(.system(
                    size: 14 * scaleFactor,
                    weight: .medium)
                )
                .foregroundColor(.white)
        }
    }
}

#Preview("Default") {
    OkNavigationInfraredButton(
        data: .init(
            upKeyId: .unknown,
            leftKeyId: .unknown,
            downKeyId: .unknown,
            rightKeyId: .unknown,
            okKeyId: .unknown
        )
    )
    .frame(width: 300, height: 300)
    .environment(\.layoutState, .default)
}

#Preview("Disabled") {
    OkNavigationInfraredButton(
        data: .init(
            upKeyId: .unknown,
            leftKeyId: .unknown,
            downKeyId: .unknown,
            rightKeyId: .unknown,
            okKeyId: .unknown
        )
    )
    .frame(width: 300, height: 300)
    .environment(\.layoutState, .disabled)
}

#Preview("Syncing") {
    OkNavigationInfraredButton(
        data: .init(
            upKeyId: .unknown,
            leftKeyId: .unknown,
            downKeyId: .unknown,
            rightKeyId: .unknown,
            okKeyId: .unknown
        )
    )
    .frame(width: 300, height: 300)
    .environment(\.layoutState, .syncing)
}

#Preview("Emulating") {
    OkNavigationInfraredButton(
        data: .init(
            upKeyId: .unknown,
            leftKeyId: .unknown,
            downKeyId: .unknown,
            rightKeyId: .unknown,
            okKeyId: .unknown
        )
    )
    .frame(width: 300, height: 300)
    .environment(\.layoutState, .emulating)
}

#Preview("Not supported") {
    OkNavigationInfraredButton(
        data: .init(
            upKeyId: .unknown,
            leftKeyId: .unknown,
            downKeyId: .unknown,
            rightKeyId: .unknown,
            okKeyId: .unknown
        )
    )
    .frame(width: 300, height: 300)
    .environment(\.layoutState, .notSupported)
}
