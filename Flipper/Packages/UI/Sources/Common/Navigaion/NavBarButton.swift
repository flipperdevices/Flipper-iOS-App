import SwiftUI

struct NavBarButton<Label: View>: View {
    @Environment(\.isEnabled) private var isEnabled

    var action: () -> Void
    @ViewBuilder var label: () -> Label

    var body: some View {
        Button(action: action) {
            label()
                .tappableFrame()
                .foregroundColor(.primary)
        }
        .buttonStyle(.borderless)
        .opacity(isEnabled ? 1 : 0.4)
    }
}
