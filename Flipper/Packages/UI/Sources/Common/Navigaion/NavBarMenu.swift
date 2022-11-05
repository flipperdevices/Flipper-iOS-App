import SwiftUI

struct NavBarMenu<Label: View, Content: View>: View {
    @ViewBuilder var content: () -> Content
    @ViewBuilder var label: () -> Label

    var body: some View {
        Menu(content: content) {
            label()
                .tappableFrame()
        }
        .foregroundColor(.primary)
    }
}
