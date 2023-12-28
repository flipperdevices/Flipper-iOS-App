import SwiftUI
import MarkdownUI

struct GitHubMarkdown: View {
    var text: String

    @State private var markdown: String = ""

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        Markdown(markdown)
            .markdownTextStyle {
                FontSize(14)
            }
            .markdownBlockStyle(\.heading2) { configuration in
                configuration
                    .label
                    .markdownMargin(top: .rem(0), bottom: .rem(0.5))
                    .markdownTextStyle {
                        FontWeight(.semibold)
                        FontSize(.em(1))
                    }
            }
            .task {
                formatDocument()
            }
    }

    func formatDocument() {
        markdown = text
            .replacingPullRequestURLs
            .replacingCompareURLs
            .replacingURLs
            .replacingUsers
    }
}

private extension String {

    // (^| ) - is simple guard against matching valid markdown link

    var replacingPullRequestURLs: String {
        replacingOccurrences(
            of: #"(^|\s)(https://github.com/\S+/pull/([0-9]+))"#,
            with: "$1[#$3]($2)",
            options: [.regularExpression])
    }

    var replacingCompareURLs: String {
        replacingOccurrences(
            of: #"(^|\s)(https://github.com/\S+/compare/(\S+))"#,
            with: "$1[$3]($2)",
            options: [.regularExpression])
    }

    var replacingURLs: String {
        replacingOccurrences(
            of: #"(^|\s)(https://\S+)"#,
            with: "$1[$2]($2)",
            options: [.regularExpression])
    }

    var replacingUsers: String {
        replacingOccurrences(
            of: #"(^|\s)@(\S+)"#,
            with: "$1**@$2**",
            options: [.regularExpression])
    }
}
