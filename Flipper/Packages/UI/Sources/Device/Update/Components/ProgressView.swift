import Core
import SwiftUI
import MarkdownUI

struct UpdateProgressView: View {
    let state: UpdateModel.State.Update.Progress
    let version: Update.Version
    let changelog: String

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 8) {
                Version(version)
                    .font(.system(size: 18, weight: .medium))

                UpdateProgressBar(state: state)
                    .padding(.horizontal, 24)

                UpdateProgressDescription(state: state)
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
