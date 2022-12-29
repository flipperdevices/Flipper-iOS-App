import Core
import SwiftUI

extension DeviceUpdateCard {
    struct CardStateReady: View {
        let state: VersionUpdateModel.State.Ready

        @EnvironmentObject var appState: AppState
        @EnvironmentObject var syncService: SyncService
        @EnvironmentObject var checkUpdateService: CheckUpdateService

        @State var showPauseSync = false
        @State var showCharge = false

        var updateAvailable: VersionUpdateModel {
            appState.updateAvailable
        }

        var availableFirmware: String {
            updateAvailable.available?.description ?? "unknown"
        }

        var channelColor: Color {
            switch updateAvailable.selectedChannel {
            case .development: return .development
            case .candidate: return .candidate
            case .release: return .release
            case .custom: return .custom
            }
        }

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

                    SelectChannel(
                        firmware: availableFirmware,
                        color: channelColor
                    ) {
                        checkUpdateService.onChannelSelected($0)
                    }
                    .onTapGesture {
                        checkUpdateService.updateAvailableFirmware()
                    }
                }
                .font(.system(size: 14))
                .padding(.horizontal, 12)
                .padding(.top, 4)

                Divider()

                UpdateButton(state: state) {
                    guard checkUpdateService.hasBatteryCharged else {
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
        }
    }
}
