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
    let alignment: HorizontalAlignment
    @ViewBuilder var content: () -> Content

    init(
        alignment: HorizontalAlignment = .center,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.alignment = alignment
        self.content = content
    }

    var offset: Double {
        switch alignment {
        case .leading: return -10
        case .trailing: return 10
        default: return 0
        }
    }

    var body: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            HStack(spacing: 0) {
                if alignment == .trailing {
                    Spacer()
                }
                content()
                    .offset(x: offset)
                if alignment == .leading {
                    Spacer()
                }
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
