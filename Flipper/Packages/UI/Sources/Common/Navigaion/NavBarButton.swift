import SwiftUI

struct NavBarButton<Label: View>: View {
    var action: () -> Void
    @ViewBuilder var label: () -> Label

    var body: some View {
        label()
            .tappableFrame()
            // NOTE: trying to fix iOS15 heisenbug
            .background(Color.background.opacity(0.001))
            .onTapGesture {
                action()
            }
    }
}
