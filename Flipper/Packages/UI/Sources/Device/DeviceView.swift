import Core
import SwiftUI

struct DeviceView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var flipperService: FlipperService
    @EnvironmentObject var updateService: UpdateService
    @EnvironmentObject var syncService: SyncService

    @State var showForgetAction = false
    @State var showUnsupportedVersionAlert = false

    var canSync: Bool {
        appState.status == .connected
    }

    var canPlayAlert: Bool {
        appState.flipper?.state == .connected &&
        appState.status != .unsupportedDevice
    }

    var canConnect: Bool {
        appState.flipper?.state == .disconnected ||
        appState.flipper?.state == .disconnecting ||
        appState.flipper?.state == .pairingFailed ||
        appState.flipper?.state == .invalidPairing
    }

    var canDisconnect: Bool {
        appState.flipper?.state == .connected ||
        appState.flipper?.state == .connecting
    }

    var canForget: Bool {
        appState.status != .noDevice
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                DeviceHeader(device: appState.flipper)

                ScrollView {
                    VStack(spacing: 0) {
                        if appState.status == .unsupportedDevice {
                            UnsupportedDevice()
                                .padding(.top, 24)
                                .padding(.horizontal, 14)
                        } else if appState.status != .noDevice {
                            DeviceUpdateCard { intent in
                                updateService.start(intent)
                            }
                            .padding(.top, 24)
                            .padding(.horizontal, 14)
                        }

                        if appState.status != .unsupportedDevice {
                            NavigationLink {
                                DeviceInfoView()
                            } label: {
                                DeviceInfoCard()
                                    .padding(.top, 24)
                                    .padding(.horizontal, 14)
                            }
                            .disabled(!appState.status.isAvailable)
                        }

                        VStack(spacing: 24) {
                            VStack(spacing: 0) {
                                NavigationButton(
                                    image: "Options",
                                    title: "Options"
                                ) {
                                    OptionsView()
                                }
                            }
                            .cornerRadius(10)

                            if appState.status != .noDevice {
                                VStack(spacing: 0) {
                                    ActionButton(
                                        image: "Sync",
                                        title: "Synchronize"
                                    ) {
                                        syncService.synchronize()
                                    }
                                    .disabled(!canSync)

                                    Divider()

                                    ActionButton(
                                        image: "Alert",
                                        title: "Play Alert"
                                    ) {
                                        flipperService.playAlert()
                                    }
                                    .disabled(!canPlayAlert)
                                }
                                .cornerRadius(10)
                            }

                            VStack(spacing: 0) {
                                if appState.status == .noDevice {
                                    ActionButton(
                                        image: "Connect",
                                        title: "Connect Flipper"
                                    ) {
                                        connect()
                                    }
                                } else {
                                    if canConnect {
                                        ActionButton(
                                            image: "Connect",
                                            title: "Connect"
                                        ) {
                                            connect()
                                        }
                                    }

                                    if canDisconnect {
                                        ActionButton(
                                            image: "Disconnect",
                                            title: "Disconnect"
                                        ) {
                                            disconnect()
                                        }
                                    }

                                    Divider()

                                    if canForget {
                                        ActionButton(
                                            image: "Forget",
                                            title: "Forget Flipper"
                                        ) {
                                            showForgetAction = true
                                        }
                                        .foregroundColor(.sRed)
                                    }
                                }
                            }
                            .cornerRadius(10)
                        }
                        .padding(.vertical, 24)
                        .padding(.horizontal, 14)

                        Color.clear.alert(
                            isPresented: $showUnsupportedVersionAlert
                        ) {
                            .unsupportedDeviceIssue
                        }
                    }
                }
                .background(Color.background)
                .actionSheet(isPresented: $showForgetAction) {
                    .init(
                        title: Text("This action won't delete your keys"),
                        buttons: [
                            .destructive(Text("Forget Flipper")) {
                                flipperService.forgetDevice()
                            },
                            .cancel()
                        ]
                    )
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(.stack)
        .navigationBarColors(foreground: .primary, background: .a1)
        .onChange(of: appState.status) { status in
            if status == .unsupportedDevice {
                showUnsupportedVersionAlert = true
            }
        }
        .fullScreenCover(item: $appState.update.intent) { intent in
            DeviceUpdateView(intent: intent)
        }
    }

    func connect() {
        if appState.status == .noDevice {
            flipperService.pairDevice()
        } else {
            flipperService.connect()
        }
    }

    func disconnect() {
        flipperService.disconnect()
    }
}
