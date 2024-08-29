import SwiftUI
import Core

struct NavigationInfraredButton: View {
    @Environment(\.layoutScaleFactor) private var scaleFactor

    let data: InfraredButtonData.Navigation

    var body: some View {
        GeometryReader { proxy in
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

                        buttonOk()
                            .frame(
                                width: proxy.size.width / 3,
                                height: proxy.size.height / 3
                            )
                            .onEmulate(keyID: data.okKeyId)


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
    private func buttonOk() -> some View {
        ZStack {
            Circle()
                .fill(Color.black60)

            Circle()
                .strokeBorder(.black, lineWidth: 3)

            Text("OK")
                .font(.system(
                    size: 14 * scaleFactor,
                    weight: .medium)
                )
                .foregroundColor(.white)
        }
    }
}
