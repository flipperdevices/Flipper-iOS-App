import SwiftUI

struct Card<Content>: View where Content: View {
    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        VStack(spacing: 0) {
            content()
        }
        .foregroundColor(.primary)
        .background(Color.groupedBackground)
        .cornerRadius(10)
    }
}
