import SwiftUI

extension DeviceUpdateView {
    struct UpdateProgressView: View {
        @StateObject var viewModel: DeviceUpdateViewModel

        var description: String {
            switch viewModel.state {
            case .downloadingFirmware:
                return "Downloading from update server..."
            case .prepearingForUpdate:
                return "Preparing for update..."
            case .uploadingFirmware:
                return "Uploading firmware to Flipper..."
            case .canceling:
                return "Canceling..."
            default:
                return ""
            }
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

                        Text(viewModel.changelog)
                            .font(.system(size: 15))
                            .padding(.vertical, 14)
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
            viewModel.state == .prepearingForUpdate
                ? "..."
                : "\(Int(viewModel.progress * 100))%"
        }

        var color: Color {
            switch viewModel.state {
            case .downloadingFirmware: return .sGreenUpdate
            case .prepearingForUpdate, .uploadingFirmware, .canceling: return .a2
            default: return .clear
            }
        }

        var body: some View {
            ZStack {
                RoundedRectangle(cornerRadius: 9)
                    .stroke(color, lineWidth: 3)

                GeometryReader { reader in
                    color.frame(width: reader.size.width * viewModel.progress)
                }

                HStack {
                    Image(image)
                        .padding([.leading, .top, .bottom], 9)

                    Spacer()

                    Text(text)
                        .foregroundColor(.white)
                        .font(.haxrCorpNeue(size: 40))
                        .padding(.bottom, 4)

                    Spacer()

                    Image(image)
                        .padding([.leading, .top, .bottom], 9)
                        .opacity(0)
                }
            }
            .frame(height: 46)
            .background(color.opacity(0.54))
            .cornerRadius(9)
        }
    }
}
