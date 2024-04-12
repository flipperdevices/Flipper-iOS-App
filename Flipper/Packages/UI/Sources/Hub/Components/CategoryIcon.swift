import Core
import SwiftUI
import Foundation

struct CategoryIcon: View {
    @Environment(\.colorScheme) var colorScheme

    let url: URL?
    let fixme: Bool

    init(_ url: URL?, fixme: Bool = false) {
        self.url = url
        self.fixme = fixme
    }

    private var color: Color {
        switch colorScheme {
        case .dark: return .black40
        default: return .black60
        }
    }

    var body: some View {
        SVGCachedImage(
            url: url,
            placeholder: {
                AnimatedPlaceholder()
            },
            error: {
                Image("UnknownCategory")
                    .renderingMode(.template)
            }
        )
        .foregroundColor(fixme ? .primary : color)
    }
}
