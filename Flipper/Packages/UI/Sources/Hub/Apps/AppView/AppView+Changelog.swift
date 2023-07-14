import Core
import SwiftUI

import MarkdownUI

extension AppView {
    struct Changelog: View {
        let changelog: String

        @State private var showMore = false

        private var shortChangelog: String {
            changelog
                .split(separator: "\n")
                .prefix(5)
                .joined(separator: "\n")
        }

        struct Title: View {
            var body: some View {
                Text("Changelog")
                    .font(.system(size: 18, weight: .bold))
            }
        }

        var body: some View {
            VStack(alignment: .leading, spacing: 2) {
                VStack(alignment: .leading, spacing: 8) {
                    Title()

                    Markdown(showMore ? changelog : shortChangelog)
                        .customMarkdownStyle()
                        .lineLimit(showMore ? nil : 4)
                }

                HStack {
                    Spacer()
                    Button {
                        showMore.toggle()
                    } label: {
                        Text(showMore ? "Less" : "More")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.black30)
                    }
                }
            }
            .foregroundColor(.primary)
        }
    }
}
