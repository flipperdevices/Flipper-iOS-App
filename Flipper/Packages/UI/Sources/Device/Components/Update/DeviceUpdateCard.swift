import SwiftUI

struct DeviceUpdateCard: View {
    @StateObject var viewModel: DeviceUpdateCardModel

    var description: String {
        switch viewModel.state {
        case .disconnected:
            return "Connect to Flipper to see available updates"
        case .connecting:
            return "Connecting to Flipper..."
        case .noUpdates:
            return "There are no updates in selected channel"
        case .versionUpdate:
            return "Update Flipper to the latest version"
        case .channelUpdate:
            return "Firmware on Flipper doesn’t match update channel. " +
                "Selected version will be installed."
        case .updateInProgress:
            return "Now Flipper is updating in offline mode. " +
                "Look at device screen for info and wait for reconnect."
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

                if viewModel.state == .disconnected {
                    VStack(spacing: 2) {
                        Image("UpdateNoDevice")
                        Text(description)
                            .font(.system(size: 14, weight: .medium))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.black30)
                            .padding(.horizontal, 12)
                    }
                    .padding(.top, 26)
                    .padding(.bottom, 26)
                } else if viewModel.state == .connecting {
                    VStack(spacing: 4) {
                        Spinner()
                        Text(description)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.black30)
                    }
                    .padding(.top, 36)
                    .padding(.bottom, 36)
                } else if viewModel.state == .updateInProgress {
                    UpdateStartedImage()
                        .padding(.top, 12)
                        .padding(.horizontal, 12)

                    Text("Update started...")
                        .padding(.top, 8)

                    VStack {
                        Text(description)
                            .font(.system(size: 14, weight: .medium))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.black30)
                    }
                    .frame(height: 40)
                    .padding(.top, 8)
                    .padding(.bottom, 8)
                    .padding(.horizontal, 12)
                } else {
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
                                    .foregroundColor(viewModel.availableFirmwareColor)
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.black30)
                            }
                        }
                        .onTapGesture {
                            viewModel.updateAvailableFirmware()
                        }
                    }
                    .font(.system(size: 14))
                    .padding(.horizontal, 12)
                    .padding(.top, 18)

                    Divider()
                        .padding(.top, 12)

                    UpdateButton(viewModel: viewModel)

                    VStack {
                        Text(description)
                            .font(.system(size: 12, weight: .medium))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.black16)
                    }
                    .padding(.top, 5)
                    .padding(.bottom, 8)
                    .padding(.horizontal, 12)
                }
            }
        }
        .fullScreenCover(isPresented: $viewModel.showUpdateView) {
            DeviceUpdateView(viewModel: .init(
                isPresented: $viewModel.showUpdateView,
                channel: viewModel.channel,
                firmware: viewModel.availableFirmwareVersion,
                onSuccess: viewModel.onSuccess
            ))
        }
    }
}

struct UpdateButton: View {
    @StateObject var viewModel: DeviceUpdateCardModel

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

struct UpdateStartedImage: View {
    @Environment(\.colorScheme) var colorScheme

    var image: String {
        colorScheme == .light ? "UpdateStartedLight" : "UpdateStartedDark"
    }

    var body: some View {
        Image(image)
    }
}
