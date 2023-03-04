import Core
import SwiftUI

struct DeviceUpdateCard: View {
    @EnvironmentObject var updateModel: UpdateModel
    @Environment(\.scenePhase) private var scenePhase

    @State private var showUpdate = false

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
                case .busy(.checkingForUpdate):
                    CardStateBusy()

                case .busy(.updateInProgress):
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
        .task {
            update()
        }
    }

    func update() {
        updateModel.updateAvailableFirmware()
    }
}
