import Core
import SwiftUI

extension DeviceUpdateCard {
    struct CardStateReady: View {
        @EnvironmentObject var updateModel: UpdateModel
        @State private var showFileImporter = false

        let state: UpdateModel.State.Ready
        let startUpdate: () -> Void

        var version: Update.Version? {
            updateModel.available
        }

        var updateChannel: Update.Channel {
            get { updateModel.updateChannel }
            nonmutating set { updateModel.updateChannel = newValue }
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
                    UpdateChannelLabel()

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
                            "Use the firmware from .tgz files to update"
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
                detectCustomUpdateURL(url)
            }
        }

        func detectCustomUpdateURL(_ url: URL) {
            if url.isFileURL, url.pathExtension == "tgz" {
                customUpdateFileChosen(url)
            } else if url.host == "lab.flipper.net" {
                customUpdateURLChosen(url)
            }
        }

        func customUpdateFileChosen(_ url: URL) {
            if let firmware = Update.Firmware(decodingFileURL: url) {
                updateChannel = .custom
                updateModel.customFirmware = firmware
                startUpdate()
            }
        }

        func customUpdateURLChosen(_ url: URL) {
            if let firmware = Update.Firmware(decodingWebURL: url) {
                updateChannel = .custom
                updateModel.customFirmware = firmware
                startUpdate()
            }
        }
    }
}

private extension Update.Firmware {
    init?(decodingFileURL url: URL) {
        self.init(
            version: .init(
                name: url.lastPathComponent,
                channel: .custom),
            changelog: "",
            url: url
        )
    }

    init?(decodingWebURL url: URL) {
        let components = URLComponents(
            url: url,
            resolvingAgainstBaseURL: false
        )

        guard
            let queryItems = components?.queryItems,
            let link = queryItems.firstValue(forKey: "url"),
            let updateUrl = URL(string: link),
            let channel = queryItems.firstValue(forKey: "channel"),
            let version = queryItems.firstValue(forKey: "version")
        else { return nil }

        self.init(
            version: .init(name: "\(channel) \(version)", channel: .custom),
            changelog: "",
            url: updateUrl
        )
    }
}

private extension Array where Element == URLQueryItem {
    func firstValue(forKey key: String) -> String? {
        first { $0.name == key }?.value
    }
}
