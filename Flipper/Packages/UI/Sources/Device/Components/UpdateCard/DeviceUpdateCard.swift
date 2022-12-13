import Core
import SwiftUI

struct DeviceUpdateCard: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var networkService: NetworkService
    @EnvironmentObject var checkUpdateService: CheckUpdateService
    @EnvironmentObject var syncService: SyncService
    @Environment(\.scenePhase) private var scenePhase

    let update: (Update.Intent) -> Void

    var viewModel: CheckUpdateService {
        checkUpdateService
    }

    var updateAvailable: VersionUpdateModel {
        get { appState.updateAvailable }
        nonmutating set { appState.updateAvailable = newValue }
    }

    var channel: Update.Channel {
        get {
            updateAvailable.selectedChannel
        }
        nonmutating set {
            updateAvailable.selectedChannel = newValue
        }
    }

    @State var showUpdateView = false
    @State var showConfirmUpdate = false
    @State var showPauseSync = false
    @State var showCharge = false

    @State var updateVersion = ""
    @State var showUpdateFailed = false
    @State var showUpdateSucceeded = false

    var description: String {
        switch updateAvailable.state {
        case .busy(.connecting):
            return "Connecting to Flipper..."
        case .busy(.loadingManifest):
            return "Connecting to Flipper..."
        case .busy(.updateInProgress):
            return "Flipper is updating in offline mode. " +
                "Look at the device screen for info and wait for reconnection."
        case .ready(.noUpdates):
            return "There are no updates in selected channel"
        case .ready(.versionUpdate):
            return "Update Flipper to the latest version"
        case .ready(.channelUpdate):
            return "Firmware on Flipper doesn’t match update channel. " +
                "Selected version will be installed."
        case .error(.noCard):
            return "Install SD card in Flipper to update firmware"
        case .error(.noInternet):
            return "Can’t connect to update server"
        case .error(.cantConnect):
            return "Can’t connect to update server"
        case .error(.noDevice):
            return "Connect to Flipper to see available updates"
        }
    }

    var availableFirmware: String {
        updateAvailable.available?.description ?? "unknown"
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

                switch updateAvailable.state {
                case .busy(.connecting), .busy(.loadingManifest):
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

                case .busy(.updateInProgress):
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
                case .ready(let state):
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

                    UpdateButton(state: state) {
                        guard viewModel.hasBatteryCharged else {
                            showCharge = true
                            return
                        }
                        guard appState.status != .synchronizing else {
                            showPauseSync = true
                            return
                        }
                        checkUpdateService.onUpdatePressed()
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
                case .error(.noCard):
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

                case .error(.noInternet):
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

                case .error(.cantConnect):
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

                case .error(.noDevice):
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
                }
            }
        }
        .alert(
            "Update Firmware?",
            isPresented: $showConfirmUpdate,
            presenting: updateAvailable.intent
        ) { intent in
            Button("Cancel") { }
            Button("Update") {
                update(intent)
                // FIXME: wait for event
                updateAvailable.state = .busy(.updateInProgress)
            }
        } message: { intent in
            Text(
                "New Firmware \(intent.to) " +
                "will be installed")
        }
        .alert(
            "Pause Synchronization?",
            isPresented: $showPauseSync
        ) {
            Button("Continue") { }
            Button("Pause") {
                syncService.cancelSync()
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
                firmwareVersion: updateVersion)
        }
        .customAlert(isPresented: $showUpdateFailed) {
            UpdateFailedAlert(
                isPresented: $showUpdateFailed,
                firmwareVersion: updateVersion)
        }
        .onChange(of: updateAvailable.intent) { intent in
            if intent != nil {
                showConfirmUpdate = true
            }
        }
        .onChange(of: appState.update.result) { result in
            updateVersion = updateAvailable.intent?.to.description ?? "unknown"
            switch result {
            case .completed: showUpdateSucceeded = true
            case .failed: showUpdateFailed = true
            default: break
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
        .task {
            viewModel.updateAvailableFirmware(for: channel)
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
