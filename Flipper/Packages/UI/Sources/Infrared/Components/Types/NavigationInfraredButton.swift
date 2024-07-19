import SwiftUI
import Core
import Infrared

struct NavigationInfraredButton: View {
    @Environment(\.layoutScaleFactor) private var scaleFactor

    let data: NavigationButtonData

    var body: some View {
        GeometryReader { proxy in
            Circle()
                .fill(Color.black80)
                .overlay {
                    Grid {
                        GridRow {
                            Spacer()

                            buttonNavigation()

                            Spacer()
                        }
                        GridRow {
                            buttonNavigation()
                                .rotationEffect(.degrees(-90))

                            buttonOk()
                                .frame(
                                    width: proxy.size.width / 3,
                                    height: proxy.size.height / 3
                                )

                            buttonNavigation()
                                .rotationEffect(.degrees(90))
                        }
                        GridRow {
                            Spacer()

                            buttonNavigation()
                                .rotationEffect(.degrees(180))

                            Spacer()
                        }
                    }
                }
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
