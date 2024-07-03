import SwiftUI

struct InfraredSquareButton<Content: View>: View {
    @Environment(\.layoutScaleFactor) private var scaleFactor

    @ViewBuilder var content: () -> Content

    var body: some View {
        RoundedRectangle(cornerRadius: 12 * scaleFactor)
            .fill(Color.black80)
            .overlay {
                content()
            }
    }
}
