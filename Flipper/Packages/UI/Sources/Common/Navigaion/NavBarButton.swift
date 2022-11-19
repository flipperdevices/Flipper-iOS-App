import SwiftUI

struct NavBarButton<Label: View>: View {
    var action: () -> Void
    @ViewBuilder var label: () -> Label

    var body: some View {
        label()
            .tappableFrame()
            .onTapGesture {
                action()
            }
    }
}
