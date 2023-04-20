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
                VStack(alignment: .leading, spacing: 14) {
                    Text("What’s New")
                        .font(.system(size: 18, weight: .bold))

                    GitHubMarkdown(changelog)
                }
                .padding(.top, 24)
                .padding(.bottom, 14)
                .padding(.horizontal, 14)
            }

            Divider()
                .padding(.bottom, 7)
        }
    }
}
