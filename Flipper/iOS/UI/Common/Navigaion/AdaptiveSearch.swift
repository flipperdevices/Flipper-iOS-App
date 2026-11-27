import SwiftUI

struct AdaptiveSearchField: View {
    @Binding var text: String
    let prompt: String

    var body: some View {
        SearchField(placeholder: prompt, predicate: $text)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
    }
}

@available(iOS 27.1, *)
struct AdaptiveSearchToolbarItem: ToolbarContent {
    @Binding var text: String
    @Binding var isPresented: Bool

    var body: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                if isPresented {
                    text = ""
                }
                isPresented.toggle()
            } label: {
                Label(
                    isPresented ? "Cancel search" : "Search",
                    systemImage: isPresented ? "xmark" : "magnifyingglass")
            }
        }
        .axisBehavior(.verticalPreferred)
    }
}
