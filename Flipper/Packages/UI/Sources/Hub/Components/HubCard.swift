import SwiftUI

struct HubCard<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        Group {
            content()
                .padding(12)
        }
        .background(Color.groupedBackground)
        .cornerRadius(10)
    }
}
