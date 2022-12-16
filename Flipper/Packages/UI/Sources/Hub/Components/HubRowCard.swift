import SwiftUI

struct HubRowCard<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        Card {
            content()
                .padding(12)
        }
    }
}
