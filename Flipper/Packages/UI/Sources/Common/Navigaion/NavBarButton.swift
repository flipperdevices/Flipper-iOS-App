import SwiftUI

struct NavBarButton<Label: View>: View {
    var action: () -> Void
    @ViewBuilder var label: () -> Label

    var body: some View {
        Button(action: action) {
            label()
                .tappableFrame()
                .foregroundColor(.primary)
        }
        .buttonStyle(.borderless)
    }
}
