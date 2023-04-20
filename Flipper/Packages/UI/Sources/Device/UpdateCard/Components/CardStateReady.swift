import Core
import SwiftUI

extension DeviceUpdateCard {
    struct CardStateReady: View {
        @EnvironmentObject var updateModel: UpdateModel

        let state: UpdateModel.State.Ready

        var version: Update.Version? {
            updateModel.available
        }

        var updateChannel: Update.Channel {
            get { updateModel.updateChannel }
            nonmutating set { updateModel.updateChannel = newValue }
        }

        @EnvironmentObject var device: Device
        @EnvironmentObject var synchronization: Synchronization

        @State private var showConfirmUpdate = false
        @State private var showPauseSync = false
        @State private var showCharge = false

        var description: String {
            switch state {
            case .noUpdates:
                return "There are no updates in selected channel"
            case .versionUpdate:
                return "Update Flipper to the latest version"
            case .channelUpdate:
                return "Firmware on Flipper doesn’t match update channel. " +
                    "Selected version will be installed."
            }
        }

        var body: some View {
            VStack(spacing: 0) {
                HStack {
                    Text("Update Channel")
                        .foregroundColor(.black30)

                    Spacer()

                    if let version = version {
                        SelectChannel(version: version) {
                            updateChannel = $0
                        }
                    }
                }
                .font(.system(size: 14))
                .padding(.horizontal, 12)
                .padding(.top, 4)

                Divider()

                UpdateButton(state: state) {
                    guard device.hasBatteryCharged else {
                        showCharge = true
                        return
                    }
                    guard device.status != .synchronizing else {
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
            .alert(isPresented: $showPauseSync) {
                Alert(
                    title: Text("Pause Synchronization?"),
                    message: Text(
                        "Firmware update is not possible during synchronization. " +
                        "Wait for sync to finish or pause it."
                    ),
                    primaryButton: .default(Text("Continue")),
                    secondaryButton: .destructive(Text("Pause")) {
                        synchronization.cancelSync()
                    }
                )
            }
            .alert(isPresented: $showConfirmUpdate) {
                Alert(
                    title: Text("Update Firmware?"),
                    message: Text(
                        "New Firmware \(updateModel.firmware?.version as? String ?? "") " +
                        "will be installed"
                    ),
                    primaryButton: .default(Text("Cancel")),
                    secondaryButton: .destructive(Text("Update")) {
                        updateModel.startUpdate()
                    }
                )
            }
            .customAlert(isPresented: $showCharge) {
                LowBatteryAlert(isPresented: $showCharge)
            }
        }
    }
}
