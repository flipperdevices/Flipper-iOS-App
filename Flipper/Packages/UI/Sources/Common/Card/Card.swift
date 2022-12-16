import SwiftUI

struct Card<Content>: View where Content: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        Group {
            content()
        }
        .background(Color.groupedBackground)
        .foregroundColor(.primary)
        .cornerRadius(10)
    }
}
