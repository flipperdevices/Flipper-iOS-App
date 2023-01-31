import Core
import SwiftUI

struct DeviceUpdateCard: View {
    @EnvironmentObject var device: Device
    @EnvironmentObject var updateService: UpdateService
    @EnvironmentObject var checkUpdateService: CheckUpdateService
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @Environment(\.scenePhase) private var scenePhase

    @AppStorage(.updateChannel) var channel: Update.Channel = .release

    var updateVersion: String {
        checkUpdateService.intent?.to.description ?? "unknown"
    }

    @State var intent: Update.Intent? = nil
    @State var showConfirmUpdate = false

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

                switch checkUpdateService.state {
                case .busy(.connecting), .busy(.loadingManifest):
                    CardStateBusy()

                case .busy(.updateInProgress):
                    CardStateInProgress()

                case .ready(let state):
                    CardStateReady(state: state, channel: $channel)

                case .error(.noCard):
                    CardNoSDError()

                case .error(.noInternet):
                    CardNoInternetError(channel: channel)

                case .error(.cantConnect):
                    CardCantConnectError(channel: channel)

                case .error(.noDevice):
                    CardNoDeviceError()
                }
            }
        }
        .alert(
            "Update Firmware?",
            isPresented: $showConfirmUpdate,
            presenting: checkUpdateService.intent
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
        .onChange(of: checkUpdateService.intent) { intent in
            if intent != nil {
                showConfirmUpdate = true
            }
        }
        .onOpenURL { url in
            if url.isFirmwareURL {
                onCustomURLOpened(url: url)
            }
        }
        .onChange(of: scenePhase) { phase in
            if phase == .active {
                checkUpdateService.updateAvailableFirmware(for: channel)
            }
        }
        .onChange(of: networkMonitor.isAvailable) {
            checkUpdateService.onNetworkStatusChanged(available: $0)
        }
        .fullScreenCover(item: $intent) { intent in
            DeviceUpdateView(intent: intent)
        }
        .task {
            checkUpdateService.updateAvailableFirmware(for: channel)
        }
    }

    func onCustomURLOpened(url: URL) {
        channel = .custom(url)
        checkUpdateService.updateVersion(for: channel)
    }
}

private extension URL {
    var isFirmwareURL: Bool {
        pathExtension == "tgz"
    }
}
