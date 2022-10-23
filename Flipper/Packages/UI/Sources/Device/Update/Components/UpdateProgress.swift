import SwiftUI
import MarkdownUI

extension DeviceUpdateView {
    struct UpdateProgressView: View {
        @StateObject var viewModel: DeviceUpdateViewModel

        var description: String {
            switch viewModel.state {
            case .downloadingFirmware:
                return "Downloading from update server..."
            case .preparingForUpdate:
                return "Preparing for update..."
            case .uploadingFirmware:
                return "Uploading firmware to Flipper..."
            case .canceling:
                return "Canceling..."
            default:
                return ""
            }
        }

        var changelog: Document {
            (try? .init(markdown: viewModel.changelog)) ?? .init(blocks: [])
        }

        var body: some View {
            VStack(spacing: 0) {
                Text(viewModel.availableFirmware)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(viewModel.availableFirmwareColor)
                    .padding(.top, 14)
                UpdateProgress(viewModel: viewModel)
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

                        Markdown(changelog)
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
        @StateObject var viewModel: DeviceUpdateViewModel

        var image: String {
            switch viewModel.state {
            case .downloadingFirmware: return "DownloadingUpdate"
            default: return "UploadingUpdate"
            }
        }

        var text: String {
            viewModel.state == .preparingForUpdate
                ? "..."
                : "\(Int(viewModel.progress * 100))%"
        }

        var color: Color {
            switch viewModel.state {
            case .downloadingFirmware: return .sGreenUpdate
            case .preparingForUpdate, .uploadingFirmware, .canceling: return .a2
            default: return .clear
            }
        }

        var body: some View {
            ProgressBarView(
                image: image,
                text: text,
                color: color,
                progress: viewModel.progress)
        }
    }
}
