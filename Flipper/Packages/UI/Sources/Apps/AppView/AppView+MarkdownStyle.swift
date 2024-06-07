import SwiftUI
import MarkdownUI

extension View {
    func customMarkdownStyle() -> some View {
        self
            .markdownTextStyle {
                FontSize(14)
            }
            .markdownBlockStyle(\.heading1) { configuration in
                configuration
                    .label
                    .markdownMargin(top: .rem(0), bottom: .rem(0.5))
                    .markdownTextStyle {
                        FontWeight(.semibold)
                        FontSize(14)
                    }
            }
            .markdownBlockStyle(\.heading2) { configuration in
                configuration
                    .label
                    .markdownMargin(top: .rem(0), bottom: .rem(0.5))
                    .markdownTextStyle {
                        FontWeight(.semibold)
                        FontSize(14)
                    }
            }
    }
}
