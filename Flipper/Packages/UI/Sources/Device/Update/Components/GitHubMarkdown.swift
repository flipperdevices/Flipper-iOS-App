import SwiftUI
import MarkdownUI

struct GitHubMarkdown: View {
    var text: String

    @State private var document: Document?

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        Markdown(document ?? .init(blocks: []))
            .task {
                formatDocument()
            }
    }

    func formatDocument() {
        let markdown = text
            .replacingPullRequestURLs
            .replacingCompareURLs
            .replacingURLs
            .replacingUsers
        document = try? .init(markdown: markdown)
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
