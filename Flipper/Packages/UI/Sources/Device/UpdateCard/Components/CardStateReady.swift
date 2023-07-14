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
        @State private var showFileImporter = false

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

                if updateChannel == .custom {
                    ChooseFileButton {
                        showFileImporter = true
                    }

                    VStack {
                        Text(
                            "Use the firmware (.tgz) from your files to update"
                        )
                        .font(.system(size: 12, weight: .medium))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.black16)
                    }
                    .padding(.top, 5)
                    .padding(.bottom, 8)
                    .padding(.horizontal, 12)
                } else {
                    UpdateButton(state: state) {
                        startUpdate()
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
            .customAlert(isPresented: $showPauseSync) {
                PauseSyncAlert(
                    isPresented: $showPauseSync,
                    installedVersion: updateModel.installed!,
                    availableVersion: updateModel.available!
                ) {
                    synchronization.cancelSync()
                    updateModel.startUpdate()
                }
            }
            .customAlert(isPresented: $showConfirmUpdate) {
                ConfirmUpdateAlert(
                    isPresented: $showConfirmUpdate,
                    installedVersion: updateModel.installed!,
                    availableVersion: updateModel.available!
                ) {
                    updateModel.startUpdate()
                }
            }
            .customAlert(isPresented: $showCharge) {
                LowBatteryAlert(isPresented: $showCharge)
            }
            .fileImporter(
                isPresented: $showFileImporter,
                allowedContentTypes: [.gzip]
            ) { result in
                guard case .success(let url) = result else {
                    return
                }
                customUpdateFileChosen(url)
            }
            .onOpenURL { url in
                if url.isFileURL, url.pathExtension == "tgz" {
                    updateChannel = .custom
                    customUpdateFileChosen(url)
                }
            }
        }

        func customUpdateFileChosen(_ url: URL) {
            updateModel.customFirmware = .init(
                version: .init(
                    name: url.lastPathComponent,
                    channel: .custom),
                changelog: "",
                url: url
            )
            startUpdate()
        }

        func startUpdate() {
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
    }
}
