import Core
import SwiftUI
import MarkdownUI

extension DeviceUpdateView {
    struct UpdateProgressView: View {
        let state: Updater.State.Busy
        let version: Update.Version
        let changelog: String

        var description: String {
            switch state {
            case .downloading:
                return "Downloading from update server..."
            case .preparing:
                return "Preparing for update..."
            case .uploading:
                return "Uploading firmware to Flipper..."
            default:
                return ""
            }
        }

        var body: some View {
            VStack(spacing: 0) {
                Version(version)
                    .font(.system(size: 18, weight: .medium))
                    .padding(.top, 14)
                UpdateProgress(state: state)
                    .padding(.top, 8)
                    .padding(.horizontal, 24)
                Text(description)
                    .font(.system(size: 14, weight: .medium))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black30)
                    .padding(.top, 8)

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

    struct UpdateProgress: View {
        let state: Updater.State.Busy

        var image: String {
            switch state {
            case .downloading: return "DownloadingUpdate"
            default: return "UploadingUpdate"
            }
        }

        var text: String? {
            state == .preparing
                ? "..."
                : nil
        }

        var color: Color {
            switch state {
            case .downloading: return .sGreenUpdate
            case .preparing, .uploading: return .a2
            }
        }

        var progress: Double {
            switch state {
            case .downloading(let progress): return progress
            case .uploading(let progress): return progress
            default: return 0
            }
        }

        var body: some View {
            ProgressBarView(
                color: color,
                image: image,
                progress: progress,
                text: text)
        }
    }
}
