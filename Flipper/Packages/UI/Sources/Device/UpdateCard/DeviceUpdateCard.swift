import Core
import SwiftUI

struct DeviceUpdateCard: View {
    @EnvironmentObject var updateModel: UpdateModel
    @Environment(\.scenePhase) private var scenePhase

    @State private var showUpdate = false

    @State private var showUpdateSuccess = false
    @State private var showUpdateFailure = false

    private var updateVersion: String {
        updateModel.intent?.desiredVersion.description ?? ""
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
        .fullScreenCover(isPresented: $updateModel.showUpdate) {
            if let firmware = updateModel.firmware {
                DeviceUpdateView(firmware: firmware)
            }
        }
        .onChange(of: updateModel.state) { state in
            guard case .update(.result(let result)) = state else {
                return
            }
            switch result {
            case .succeeded: showUpdateSuccess = true
            case .failed: showUpdateFailure = true
            default: break
            }
        }
        .customAlert(isPresented: $showUpdateSuccess) {
            UpdateSucceededAlert(
                isPresented: $showUpdateSuccess,
                firmwareVersion: updateVersion
            )
        }
        .customAlert(isPresented: $showUpdateFailure) {
            UpdateFailedAlert(
                isPresented: $showUpdateFailure,
                firmwareVersion: updateVersion
            )
        }
        .task {
            await update()
        }
    }

    func update() {
        updateModel.updateAvailableFirmware()
    }
}
