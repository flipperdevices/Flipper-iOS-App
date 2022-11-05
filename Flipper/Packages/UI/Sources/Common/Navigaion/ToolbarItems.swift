import SwiftUI

struct LeadingToolbarItems<Content: View>: ToolbarContent {
    @ViewBuilder var content: () -> Content

    var body: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            HStack(spacing: 0) {
                content()
            }
            .offset(x: -10)
        }
    }
}

struct TrailingToolbarItems<Content: View>: ToolbarContent {
    @ViewBuilder var content: () -> Content

    var body: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            HStack(spacing: 0) {
                content()
            }
            .offset(x: 10)
        }
    }
}
