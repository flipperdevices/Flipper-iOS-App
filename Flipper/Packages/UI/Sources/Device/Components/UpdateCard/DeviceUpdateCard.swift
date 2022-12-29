import Core
import SwiftUI

struct DeviceUpdateCard: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var networkService: NetworkService
    @EnvironmentObject var checkUpdateService: CheckUpdateService
    @Environment(\.scenePhase) private var scenePhase

    var updateAvailable: VersionUpdateModel {
        appState.updateAvailable
    }

    var updateVersion: String {
        updateAvailable.intent?.to.description ?? "unknown"
    }

    @State var intent: Update.Intent? = nil
    @State var showConfirmUpdate = false

    @State var showUpdateFailed = false
    @State var showUpdateSucceeded = false

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
                    CardStateBusy()

                case .busy(.updateInProgress):
                    CardStateInProgress()

                case .ready(let state):
                    CardStateReady(state: state)

                case .error(.noCard):
                    CardNoSDError()

                case .error(.noInternet):
                    CardNoInternetError()

                case .error(.cantConnect):
                    CardCantConnectError()

                case .error(.noDevice):
                    CardNoDeviceError()
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
                self.intent = intent
                checkUpdateService.onUpdateStarted(intent)
            }
        } message: { intent in
            Text(
                "New Firmware \(intent.to) " +
                "will be installed")
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
        .onReceive(appState.update.result) { result in
            switch result {
            case .success: showUpdateSucceeded = true
            case .failure: showUpdateFailed = true
            }
        }
        .onChange(of: appState.customFirmwareURL) { url in
            guard let url = url else { return }
            checkUpdateService.onCustomURLOpened(url: url)
        }
        .onChange(of: scenePhase) { phase in
            if phase == .active {
                checkUpdateService.updateAvailableFirmware()
            }
        }
        .onChange(of: networkService.available) {
            checkUpdateService.onNetworkStatusChanged(available: $0)
        }
        .fullScreenCover(item: $intent) { intent in
            DeviceUpdateView(intent: intent)
        }
        .task {
            checkUpdateService.updateAvailableFirmware()
        }
    }
}
