import SwiftUI
import Core

struct NavigationInfraredButton: View {
    @Environment(\.layoutScaleFactor) private var scaleFactor

    let data: InfraredButtonData.Navigation

    var body: some View {
        InfraredSquareButton {
            Grid {
                GridRow {
                    Spacer()
                    buttonNavigation()
                        .onEmulate(keyID: data.leftKeyId)
                    Spacer()
                }
                GridRow {
                    buttonNavigation()
                        .rotationEffect(.degrees(-90))
                        .onEmulate(keyID: data.upKeyId)
                    Spacer()
                    buttonNavigation()
                        .rotationEffect(.degrees(90))
                        .onEmulate(keyID: data.downKeyId)
                }
                GridRow {
                    Spacer()
                    buttonNavigation()
                        .rotationEffect(.degrees(180))
                        .onEmulate(keyID: data.rightKeyId)
                    Spacer()
                }
            }
        }
        .cornerRadius(.infinity)
    }

    @ViewBuilder
    private func buttonNavigation() -> some View {
        Image("InfraredNavigation")
            .resizable()
            .frame(
                width: 24 * scaleFactor,
                height: 24 * scaleFactor)
    }
}

#Preview("Default") {
    NavigationInfraredButton(
        data: .init(
            upKeyId: .unknown,
            leftKeyId: .unknown,
            downKeyId: .unknown,
            rightKeyId: .unknown
        )
    )
    .frame(width: 300, height: 300)
    .environment(\.layoutState, .default)
}

#Preview("Disabled") {
    NavigationInfraredButton(
        data: .init(
            upKeyId: .unknown,
            leftKeyId: .unknown,
            downKeyId: .unknown,
            rightKeyId: .unknown
        )
    )
    .frame(width: 300, height: 300)
    .environment(\.layoutState, .disabled)
}

#Preview("Syncing") {
    NavigationInfraredButton(
        data: .init(
            upKeyId: .unknown,
            leftKeyId: .unknown,
            downKeyId: .unknown,
            rightKeyId: .unknown
        )
    )
    .frame(width: 300, height: 300)
    .environment(\.layoutState, .syncing)
}

#Preview("Emulating") {
    NavigationInfraredButton(
        data: .init(
            upKeyId: .unknown,
            leftKeyId: .unknown,
            downKeyId: .unknown,
            rightKeyId: .unknown
        )
    )
    .frame(width: 300, height: 300)
    .environment(\.layoutState, .emulating)
}
