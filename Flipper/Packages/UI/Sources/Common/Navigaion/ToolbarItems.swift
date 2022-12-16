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

struct PrincipalToolbarItems<Content: View>: ToolbarContent {
    @ViewBuilder var content: () -> Content

    var body: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            HStack(spacing: 0) {
                content()
            }
            .foregroundColor(.primary)
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
