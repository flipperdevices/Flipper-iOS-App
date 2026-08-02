import SwiftUI

struct LeadingToolbarItems<Content: View>: ToolbarContent {
    @ViewBuilder var content: () -> Content

    var body: some ToolbarContent {
        if #available(iOS 26.0, *) {
            // iOS 26 compresses custom leading items to minimal width,
            // truncating text to "…" — fixedSize keeps the natural width;
            // offset compensates the extra ~14pt edge inset vs older bars
            ToolbarItem(placement: .navigationBarLeading) {
                HStack(spacing: 0) {
                    content()
                }
                .fixedSize()
                .offset(x: -14)
            }
            .sharedBackgroundVisibility(.hidden)
        } else {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack(spacing: 0) {
                    content()
                }
                .offset(x: -10)
            }
        }
    }
}

struct PrincipalToolbarItems<Content: View>: ToolbarContent {
    let alignment: HorizontalAlignment
    let expanding: Bool
    @ViewBuilder var content: () -> Content

    init(
        alignment: HorizontalAlignment = .center,
        expanding: Bool = false,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.alignment = alignment
        self.expanding = expanding
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
        if #available(iOS 26.0, *) {
            // iOS 26 hugs the principal item, so Spacer-based alignment
            // stops working — map leading/trailing onto real placements;
            // fixedSize prevents the system from truncating text to "…"
            if alignment == .leading {
                // -14 for the edge inset + -14 for the inter-item gap
                // after the back button (all call sites pair with one)
                ToolbarItem(placement: .navigationBarLeading) {
                    content()
                        .fixedSize()
                        .offset(x: -28)
                        .foregroundColor(.primary)
                }
                .sharedBackgroundVisibility(.hidden)
            } else if alignment == .trailing {
                ToolbarItem(placement: .navigationBarTrailing) {
                    content()
                        .fixedSize()
                        .offset(x: 14)
                        .foregroundColor(.primary)
                }
                .sharedBackgroundVisibility(.hidden)
            } else {
                ToolbarItem(placement: .principal) {
                    Group {
                        if expanding {
                            // flexible content (search field) — take the
                            // full bar width instead of the hugged size
                            content()
                                .frame(width: UIScreen.main.bounds.width - 32)
                        } else {
                            content()
                                .fixedSize()
                        }
                    }
                    .foregroundColor(.primary)
                }
                .sharedBackgroundVisibility(.hidden)
            }
        } else {
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
}

struct TrailingToolbarItems<Content: View>: ToolbarContent {
    @ViewBuilder var content: () -> Content

    var body: some ToolbarContent {
        if #available(iOS 26.0, *) {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 0) {
                    content()
                }
                .offset(x: 14)
            }
            .sharedBackgroundVisibility(.hidden)
        } else {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 0) {
                    content()
                }
                .offset(x: 10)
            }
        }
    }
}
