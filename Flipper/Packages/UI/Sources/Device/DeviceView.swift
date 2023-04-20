import Core
import SwiftUI

struct DeviceView: View {
    @EnvironmentObject var router: Router
    @EnvironmentObject var central: Central
    @EnvironmentObject var device: Device
    @EnvironmentObject var synchronization: Synchronization
    @EnvironmentObject var updateModel: UpdateModel

    @State private var showForgetAction = false
    @State private var showOutdatedFirmwareAlert = false
    @State private var showOutdatedMobileAlert = false

    var flipper: Flipper? {
        device.flipper
    }

    var isDeviceAvailable: Bool {
        device.status == .connected ||
        device.status == .synchronized
    }

    var isOutdatedVersion: Bool {
        device.status == .unsupported ||
        device.status == .outdatedMobile
    }

    var canSync: Bool {
        device.status == .connected
    }

    var canPlayAlert: Bool {
        flipper?.state == .connected && !isOutdatedVersion
    }

    var canConnect: Bool {
        flipper?.state == .disconnected ||
        flipper?.state == .disconnecting ||
        flipper?.state == .pairingFailed ||
        flipper?.state == .invalidPairing
    }

    var canDisconnect: Bool {
        flipper?.state == .connected ||
        flipper?.state == .connecting
    }

    var canForget: Bool {
        device.status != .noDevice
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                DeviceHeader(device: flipper)

                RefreshableScrollView(isEnabled: isDeviceAvailable) {
                    updateModel.updateAvailableFirmware()
                } content: {
                    VStack(spacing: 0) {
                        switch device.status {
                        case .unsupported:
                            OutdatedFirmwareCard()
                                .padding(.top, 24)
                                .padding(.horizontal, 14)
                        case .outdatedMobile:
                            OutdatedMobileCard()
                                .padding(.top, 24)
                                .padding(.horizontal, 14)
                        default:
                            if device.status != .noDevice {
                                DeviceUpdateCard()
                                    .padding(.top, 24)
                                    .padding(.horizontal, 14)
                            }
                            NavigationLink {
                                DeviceInfoView()
                            } label: {
                                DeviceInfoCard()
                                    .padding(.top, 24)
                                    .padding(.horizontal, 14)
                            }
                            .disabled(!isDeviceAvailable)
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

                            if device.status != .noDevice {
                                VStack(spacing: 0) {
                                    ActionButton(
                                        image: "Sync",
                                        title: "Synchronize"
                                    ) {
                                        synchronization.start()
                                    }
                                    .disabled(!canSync)

                                    Divider()

                                    ActionButton(
                                        image: "Alert",
                                        title: "Play Alert"
                                    ) {
                                        device.playAlert()
                                    }
                                    .disabled(!canPlayAlert)
                                }
                                .cornerRadius(10)
                            }

                            VStack(spacing: 0) {
                                if device.status == .noDevice {
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
                    }
                }
                .background(Color.background)
                .actionSheet(isPresented: $showForgetAction) {
                    .init(
                        title: Text("This action won't delete your keys"),
                        buttons: [
                            .destructive(Text("Forget Flipper")) {
                                device.forgetDevice()
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
        .customAlert(isPresented: $showOutdatedFirmwareAlert) {
            OutdatedFirmwareAlert(isPresented: $showOutdatedFirmwareAlert)
        }
        .customAlert(isPresented: $showOutdatedMobileAlert) {
            OutdatedMobileAlert(isPresented: $showOutdatedMobileAlert)
        }
        .onChange(of: device.status) { status in
            showOutdatedFirmwareAlert = status == .unsupported
            showOutdatedMobileAlert = status == .outdatedMobile
        }
        .onChange(of: central.state) { state in
            if state == .poweredOn {
                device.connect()
            }
        }
        .task { @MainActor in
            if central.state != .poweredOn {
                central.kick()
            }
        }
    }

    func connect() {
        if device.status == .noDevice {
            router.showWelcomeScreen()
        } else {
            device.connect()
        }
    }

    func disconnect() {
        device.disconnect()
    }
}
