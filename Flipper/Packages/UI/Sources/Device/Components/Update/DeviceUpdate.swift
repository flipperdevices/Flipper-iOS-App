import SwiftUI

struct DeviceUpdate: View {
    @StateObject var viewModel: DeviceUpdateViewModel

    var targetColor: Color {
        switch viewModel.channel {
        case .development: return .development
        case .canditate: return .candidate
        case .release: return .release
        }
    }

    var description: String {
        switch viewModel.state {
        case .noUpdates:
            return "There are no updates in selected channel"
        case .versionUpdate:
            return "Update Flipper to the latest version"
        case .channelUpdate:
            return "Firmware on Flipper doesn’t match update channel. " +
                "Selected version will be installed."
        case .downloadingFirmware:
            return "Downloading from update server..."
        case .uploadingFirmware:
            return "Uploading firmware to Flipper..."
        default:
            return ""
        }
    }

    var body: some View {
        Card {
            VStack(spacing: 0) {
                HStack {
                    Text("Firmware Update")
                        .font(.system(size: 16, weight: .bold))
                    Spacer()
                }
                .padding(.top, 12)
                .padding(.horizontal, 12)

                HStack {
                    Text("Update Channel")
                        .foregroundColor(.black30)

                    Spacer()

                    Menu {
                        Button("Development") {
                            viewModel.channel = .development
                        }
                        Button("Release") {
                            viewModel.channel = .release
                        }
                        Button("Release-Candidate") {
                            viewModel.channel = .canditate
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Spacer()
                            Text(viewModel.availableFirmware)
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(targetColor)
                            Image(systemName: "chevron.down")
                                .foregroundColor(.black30)
                        }
                    }
                }
                .font(.system(size: 14))
                .padding(.horizontal, 12)
                .padding(.top, 18)

                Divider()
                    .padding(.top, 12)

                switch viewModel.state {
                case .noUpdates, .versionUpdate, .channelUpdate:
                    UpdateButton(viewModel: viewModel)
                case .downloadingFirmware, .uploadingFirmware:
                    UpdateProgress(viewModel: viewModel)
                case .updateInProgress:
                    EmptyView()
                }

                VStack {
                    Text(description)
                        .font(.system(size: 12, weight: .medium))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.black16)
                }
                .frame(height: 48)
                .padding(.top, 8)
                .padding(.bottom, 8)
                .padding(.horizontal, 12)
            }
        }
    }
}

struct UpdateButton: View {
    @StateObject var viewModel: DeviceUpdateViewModel

    var title: String {
        switch viewModel.state {
        case .noUpdates: return "NO UPDATES"
        case .versionUpdate: return "UPDATE"
        case .channelUpdate: return "INSTALL"
        default: return ""
        }
    }

    var color: Color {
        switch viewModel.state {
        case .noUpdates: return .black20
        case .versionUpdate: return .sGreenUpdate
        case .channelUpdate: return .a1
        default: return .clear
        }
    }

    var body: some View {
        Button {
            viewModel.update()
        } label: {
            HStack {
                Spacer()
                Text(title)
                    .foregroundColor(.white)
                    .font(.custom("Born2bSportyV2", size: 40))
                Spacer()
            }
            .frame(height: 46)
            .frame(maxWidth: .infinity)
            .background(color)
            .cornerRadius(9)
            .padding(.horizontal, 12)
            .padding(.top, 12)
        }
        .disabled(viewModel.state == .noUpdates)
    }
}

struct UpdateProgress: View {
    @StateObject var viewModel: DeviceUpdateViewModel

    var image: String {
        switch viewModel.state {
        case .downloadingFirmware: return "DownloadingUpdate"
        case .uploadingFirmware: return "UploadingUpdate"
        default: return ""
        }
    }

    var color: Color {
        switch viewModel.state {
        case .downloadingFirmware: return .sGreenUpdate
        case .uploadingFirmware: return .a2
        default: return .clear
        }
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 9)
                .stroke(color, lineWidth: 3)

            GeometryReader { reader in
                color.frame(width: reader.size.width / 100 * Double(viewModel.progress))
            }

            HStack {
                Image(image)
                    .padding([.leading, .top, .bottom], 9)

                Spacer()

                Text("\(viewModel.progress)%")
                    .foregroundColor(.white)
                    .font(.custom("HelvetiPixel", fixedSize: 40))

                Spacer()

                Image(image)
                    .padding([.leading, .top, .bottom], 9)
                    .opacity(0)
            }
        }
        .background(color.opacity(0.54))
        .cornerRadius(9)
        .padding(.horizontal, 12)
        .padding(.top, 12)
    }
}
