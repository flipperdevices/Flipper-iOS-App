import Core
import SwiftUI
import MarkdownUI

struct UpdateProgressView: View {
    let state: UpdateModel.State.Update.Progress
    let version: Update.Version
    let changelog: String

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                Version(version)
                    .font(.system(size: 18, weight: .medium))
                    .padding(.top, 14)
                UpdateProgressBar(state: state)
                    .padding(.top, 8)
                    .padding(.horizontal, 24)
                UpdateProgressDescription(state: state)
                    .padding(.top, 8)
            }

            Divider()
                .padding(.top, 12)

            ScrollView {
                VStack(alignment: .leading) {
                    Text("What’s New")
                        .font(.system(size: 18, weight: .bold))
                        .padding(.top, 24)

                    GitHubMarkdown(changelog)
                        .padding(.vertical, 14)
                        .markdownStyle(
                            MarkdownStyle(
                                font: .system(size: 15),
                                measurements: .init(
                                    headingScales: .init(
                                        h1: 1.0,
                                        h2: 1.0,
                                        h3: 1.0,
                                        h4: 1.0,
                                        h5: 1.0,
                                        h6: 1.0),
                                    headingSpacing: 0.3
                                )
                            )
                        )
                }
                .padding(.horizontal, 14)
            }

            Divider()
                .padding(.bottom, 7)
        }
    }
}
