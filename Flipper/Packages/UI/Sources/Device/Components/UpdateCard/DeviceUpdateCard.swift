import Core
import SwiftUI

struct DeviceUpdateCard: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var networkService: NetworkService
    @StateObject var viewModel: CheckUpdateRefactoring = .init()
    @Environment(\.scenePhase) private var scenePhase

    var channel: Update.Channel {
        get {
            appState.update.selectedChannel
        }
        nonmutating set {
            appState.update.selectedChannel = newValue
        }
    }

    var availableFirmware: String {
        appState.update.available?.description ?? "unknown"
    }

    @State var showUpdateView = false
    @State var showConfirmUpdate = false
    @State var showPauseSync = false
    @State var showCharge = false

    @State var showUpdateFailed = false
    @State var showUpdateSucceeded = false

    var description: String {
        switch viewModel.state {
        case .noSDCard:
            return "Install SD card in Flipper to update firmware"
        case .noInternet:
            return "Can’t connect to update server"
        case .cantConnect:
            return "Can’t connect to update server"
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
            return "Flipper is updating in offline mode. " +
                "Look at the device screen for info and wait for reconnection."
        }
    }

    var channelColor: Color {
        switch channel {
        case .development: return .development
        case .candidate: return .candidate
        case .release: return .release
        case .custom: return .custom
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

                if viewModel.state == .noSDCard {
                    VStack(spacing: 2) {
                        Image("NoSDCard")
                        Text("No SD сard")
                            .font(.system(size: 14, weight: .medium))
                        HStack {
                            Text(description)
                                .font(.system(size: 14, weight: .medium))
                                .multilineTextAlignment(.center)
                                .foregroundColor(.black30)
                        }
                        .padding(.horizontal, 12)
                    }
                    .padding(.vertical, 4)

                    Button {
                        viewModel.updateStorageInfo()
                    } label: {
                        Text("Retry")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.a2)
                    }
                    .padding(.bottom, 8)
                } else if viewModel.state == .noInternet {
                    VStack(spacing: 2) {
                        Image("NoInternet")
                        Text("No Internet connection")
                            .font(.system(size: 14, weight: .medium))
                        HStack {
                            Text(description)
                                .font(.system(size: 14, weight: .medium))
                                .multilineTextAlignment(.center)
                                .foregroundColor(.black30)
                        }
                        .padding(.horizontal, 12)
                    }
                    .padding(.vertical, 4)

                    Button {
                        viewModel.updateAvailableFirmware(for: channel)
                    } label: {
                        Text("Retry")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.a2)
                    }
                    .padding(.bottom, 8)
                } else if viewModel.state == .cantConnect {
                    VStack(spacing: 2) {
                        Image("ServerError")
                        Text("Unable to download firmware")
                            .font(.system(size: 14, weight: .medium))
                        HStack {
                            Text(description)
                                .font(.system(size: 14, weight: .medium))
                                .multilineTextAlignment(.center)
                                .foregroundColor(.black30)
                        }
                        .padding(.horizontal, 12)
                    }
                    .padding(.vertical, 4)

                    Button {
                        viewModel.updateAvailableFirmware(for: channel)
                    } label: {
                        Text("Retry")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.a2)
                    }
                    .padding(.bottom, 8)
                } else if viewModel.state == .disconnected {
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
                    HStack {
                        Text("Update Channel")
                            .foregroundColor(.black30)

                        Spacer()

                        AnimatedPlaceholder()
                            .frame(width: 90, height: 17)
                    }
                    .font(.system(size: 14))
                    .padding(.horizontal, 12)
                    .padding(.top, 18)
                    .padding(.bottom, 12)

                    Divider()

                    AnimatedPlaceholder()
                        .frame(height: 46)
                        .padding(12)
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
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                } else {
                    HStack {
                        Text("Update Channel")
                            .foregroundColor(.black30)

                        Spacer()

                        SelectChannel(
                            firmware: availableFirmware,
                            color: channelColor
                        ) {
                            onChannelSelected($0)
                        }
                        .onTapGesture {
                            viewModel.updateAvailableFirmware(for: channel)
                        }
                    }
                    .font(.system(size: 14))
                    .padding(.horizontal, 12)
                    .padding(.top, 4)

                    Divider()

                    UpdateButton(state: viewModel.state) {
                        guard viewModel.hasBatteryCharged else {
                            showCharge = true
                            return
                        }
                        guard appState.status != .synchronizing else {
                            showPauseSync = true
                            return
                        }
                        showConfirmUpdate = true
                    }

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
        .alert(
            "Update Firmware?",
            isPresented: $showConfirmUpdate
        ) {
            Button("Cancel") { }
            Button("Update") {
                showUpdateView = true
            }
        } message: {
            Text(
                "New Firmware \(availableFirmware) " +
                "will be installed")
        }
        .alert(
            "Pause Synchronization?",
            isPresented: $showPauseSync
        ) {
            Button("Continue") { }
            Button("Pause") {
                appState.cancelSync()
            }
        } message: {
            Text(
                "Firmware update is not possible during synchronization. " +
                "Wait for sync to finish or pause it.")
        }
        .customAlert(isPresented: $showCharge) {
            LowBatteryAlert(isPresented: $showCharge)
        }
        .customAlert(isPresented: $showUpdateSucceeded) {
            UpdateSucceededAlert(
                isPresented: $showUpdateSucceeded,
                firmwareVersion: appState.update.updateInProgress?.to.version.version ?? "unknown")
        }
        .customAlert(isPresented: $showUpdateFailed) {
            UpdateFailedAlert(
                isPresented: $showUpdateFailed,
                firmwareVersion: appState.update.updateInProgress?.to.version.version ?? "unknown")
        }
        .fullScreenCover(isPresented: $showUpdateView) {
            DeviceUpdateView(
                isPresented: $showUpdateView,
                channel: channel,
                firmware: appState.update.available?.version,
                onSuccess: viewModel.onUpdateStarted,
                onFailure: viewModel.onUpdateFailed
            )
        }
        .onReceive(viewModel.updateResult) { result in
            switch result {
            case .completed: showUpdateSucceeded = true
            case .failed: showUpdateFailed = true
            default: break
            }
        }
        .onChange(of: viewModel.state) { state in
            if state == .connecting {
                viewModel.updateAvailableFirmware(for: channel)
            }
        }
        .onChange(of: appState.customFirmwareURL) { url in
            guard let url = url else {
                return
            }
            self.channel = .custom(url)
        }
        .onChange(of: scenePhase) { phase in
            if phase == .active {
                viewModel.updateAvailableFirmware(for: channel)
            }
        }
        .onChange(of: networkService.available) {
            viewModel.onNetworkStatusChanged(available: $0)
        }
    }

    func onChannelSelected(_ channel: String) {
        switch channel {
        case "Release": self.channel = .release
        case "Release-Candidate": self.channel = .candidate
        case "Development": self.channel = .development
        default: break
        }
        viewModel.updateVersion(for: self.channel)
    }
}
