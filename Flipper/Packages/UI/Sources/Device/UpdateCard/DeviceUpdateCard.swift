import Core
import SwiftUI

struct DeviceUpdateCard: View {
    @EnvironmentObject var updateModel: UpdateModel
    @Environment(\.scenePhase) private var scenePhase

    @State private var showUpdate = false

    @State private var showUpdateSuccess = false
    @State private var showUpdateFailure = false

    @AppStorage(.installingVersion) var installInProgress = ""

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

                switch updateModel.state {
                case .loading:
                    CardStateBusy()

                case .update:
                    CardStateInProgress()

                case .ready(let state):
                    CardStateReady(state: state)

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
        .onChange(of: scenePhase) { phase in
            if phase == .active {
                updateModel.updateAvailableFirmware()
            }
        }
        .fullScreenCover(isPresented: $updateModel.showUpdate) {
            if let firmware = updateModel.firmware {
                DeviceUpdateView(firmware: firmware)
            }
        }
        .onChange(of: updateModel.installed) { installed in
            if let installed = installed, !installInProgress.isEmpty {
                showUpdateSuccess = installed.description == installInProgress
                showUpdateFailure = installed.description != installInProgress
            }
        }
        .customAlert(isPresented: $showUpdateSuccess) {
            UpdateSucceededAlert(
                isPresented: $showUpdateSuccess,
                firmwareVersion: installInProgress
            )
            .onDisappear {
                installInProgress = ""
            }
        }
        .customAlert(isPresented: $showUpdateFailure) {
            UpdateFailedAlert(
                isPresented: $showUpdateFailure,
                firmwareVersion: installInProgress
            )
            .onDisappear {
                installInProgress = ""
            }
        }
        .task {
            update()
        }
    }

    func update() {
        updateModel.updateAvailableFirmware()
    }
}
