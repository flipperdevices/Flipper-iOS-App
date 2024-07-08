import Core
import SwiftUI

struct DeviceUpdateCard: View {
    @EnvironmentObject var updateModel: UpdateModel
    @EnvironmentObject var device: Device
    @EnvironmentObject var synchronization: Synchronization
    @Environment(\.scenePhase) private var scenePhase

    @State private var showUpdate = false
    @State private var showChangelog = false

    @Environment(\.alerts.device.showUpdateSuccess) var showUpdateSuccess
    @Environment(\.alerts.device.showUpdateFailure) var showUpdateFailure
    @Environment(\.alerts.device.showConfirmUpdate) var showConfirmUpdate

    @State private var showPauseSync = false
    @State private var showCharge = false

    private var updateVersion: String {
        updateModel.intent?.desiredVersion.description ?? ""
    }

    private var isWhatsNewVisible: Bool {
        guard
            updateModel.firmware != nil,
            updateModel.updateChannel != .custom,
            case .ready(let state) = updateModel.state
        else { return false }

        return state == .versionUpdate || state == .channelUpdate
    }

    var body: some View {
        Card {
            VStack(spacing: 0) {
                HStack {
                    Text("Firmware Update")
                        .font(.system(size: 16, weight: .bold))
                        .padding(.vertical, 2)
                    Spacer()

                    UpdateWhatsNewButton(showChangelog: $showChangelog)
                        .opacity(isWhatsNewVisible ? 1 : 0)
                        .onTapGesture { showChangelog = true }
                }
                .padding(.top, 12)
                .padding(.horizontal, 12)

                switch updateModel.state {
                case .loading:
                    CardStateBusy()

                case .update:
                    CardStateInProgress()

                case .ready(let state):
                    CardStateReady(state: state) {
                        prepareUpdate {
                            showConfirmUpdate.wrappedValue = true
                        }
                    }

                case .error(.noCard):
                    CardNoSDError(retry: update)
                case .error(.noInternet):
                    CardNoInternetError(retry: update)
                case .error(.cantConnect):
                    CardCantConnectError(retry: update)

                case .error(.noDevice):
                    CardNoDeviceError()
                }
            }
        }
        .fullScreenCover(isPresented: $updateModel.showUpdate) {
            if let firmware = updateModel.firmware {
                DeviceUpdateView(firmware: firmware)
            }
        }
        .fullScreenCover(isPresented: $showChangelog) {
            if
                let firmware = updateModel.firmware,
                case .ready(let state) = updateModel.state
            {
                WhatsNewScreen(
                    firmware: firmware,
                    state: state
                ) {
                    prepareUpdate {
                        updateModel.startUpdate()
                    }
                }
            }
        }
        .onChange(of: updateModel.state) { state in
            guard case .update(.result(let result)) = state else {
                return
            }
            switch result {
            case .succeeded: showUpdateSuccess.wrappedValue = true
            case .failed: showUpdateFailure.wrappedValue = true
            default: break
            }
            update()
        }
        .alert(isPresented: showUpdateSuccess) {
            UpdateSucceededAlert(
                isPresented: showUpdateSuccess,
                firmwareVersion: updateVersion
            )
        }
        .alert(isPresented: showUpdateFailure) {
            UpdateFailedAlert(
                isPresented: showUpdateFailure,
                firmwareVersion: updateVersion
            )
        }
        .alert(isPresented: showConfirmUpdate) {
            ConfirmUpdateAlert(
                isPresented: showConfirmUpdate,
                installedVersion: updateModel.installed!,
                availableVersion: updateModel.available!
            ) {
                updateModel.startUpdate()
            }
        }
        .alert(isPresented: $showCharge) {
            LowBatteryAlert(isPresented: $showCharge)
        }
        .alert(isPresented: $showPauseSync) {
            PauseSyncAlert(
                isPresented: $showPauseSync,
                installedVersion: updateModel.installed!,
                availableVersion: updateModel.available!
            ) {
                synchronization.cancelSync()
                updateModel.startUpdate()
            }
        }
        .task {
            update()
        }
    }

    func update() {
        updateModel.updateAvailableFirmware()
    }

    private func prepareUpdate(action: () -> Void) {
        guard device.hasBatteryCharged else {
            showCharge = true
            return
        }
        guard device.status != .synchronizing else {
            showPauseSync = true
            return
        }
        action()
    }
}
