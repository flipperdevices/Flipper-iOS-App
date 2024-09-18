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

        private var fullChangelog: String {
            changelog
                .split(separator: "\n")
                .joined(separator: "\n")
        }

        private var showMoreButton: Bool {
            fullChangelog.count > shortChangelog.count
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

                    Markdown(showMore ? fullChangelog : shortChangelog)
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
                .opacity(showMoreButton ? 1 : 0)
            }
            .foregroundColor(.primary)
        }
    }
}
