import Core
import SwiftUI
import Notifications

struct DeviceView: View {
    @EnvironmentObject var router: Router
    @EnvironmentObject var central: Central
    @EnvironmentObject var device: Device
    @EnvironmentObject var synchronization: Synchronization
    @EnvironmentObject var updateModel: UpdateModel
    @EnvironmentObject var notifications: Notifications

    @Environment(\.scenePhase) var scenePhase

    @State private var path = NavigationPath()

    @State private var showRemoteControl = false
    @State private var showForgetAction = false
    @State private var showOutdatedFirmwareAlert = false
    @State private var showOutdatedMobileAlert = false

    @AppStorage(.notificationsSuggested) var notificationsSuggested = false
    @AppStorage(.isNotificationsOn) var isNotificationsOn = false
    @State private var showNotificationsAlert: Bool = false
    @Environment(\.notifications) var inApp

    var flipper: Flipper? {
        device.flipper
    }

    var isDeviceAvailable: Bool {
        device.status == .connected ||
        device.status == .synchronized ||
        device.status == .synchronizing
    }

    var isOutdatedVersion: Bool {
        device.status == .unsupported ||
        device.status == .outdatedMobile
    }

    var canSync: Bool {
        device.status == .connected
    }

    var canPlayAlert: Bool {
        device.flipper?.state == .connected && !isOutdatedVersion
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

    enum Destination {
        case info
        case options
    }

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 0) {
                DeviceHeader(device: flipper)

                ScrollView {
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
                            NavigationLink(value: Destination.info) {
                                DeviceInfoCard()
                                    .padding(.top, 24)
                                    .padding(.horizontal, 14)
                            }
                            .disabled(!isDeviceAvailable)

                            Button {
                                showRemoteControl = true
                            } label: {
                                RemoteControlCard()
                            }
                            .padding(.top, 24)
                            .padding(.horizontal, 14)
                        }

                        VStack(spacing: 24) {
                            VStack(spacing: 0) {
                                NavigationButton(
                                    image: "Options",
                                    title: "Options",
                                    destination: Destination.options
                                )
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
                .confirmationDialog(
                    "Forget Flipper?",
                    isPresented: $showForgetAction,
                    titleVisibility: .visible,
                    presenting: flipper
                ) { _ in
                    Button("Forget Flipper", role: .destructive) {
                        device.forgetDevice()
                    }
                } message: { flipper in
                    Text(
                        "App will no longer be paired with " +
                        "Flipper \(flipper.name)"
                    )
                }
                .refreshable(isEnabled: isDeviceAvailable) {
                    updateModel.updateAvailableFirmware()
                }
            }
            .navigationBarHidden(true)
            .navigationBarBackground(Color.a1)
            .navigationDestination(for: Destination.self) { destination in
                switch destination {
                case .info: DeviceInfoView()
                case .options: OptionsView()
                }
            }
        }
        .alert(isPresented: $showOutdatedFirmwareAlert) {
            OutdatedFirmwareAlert(isPresented: $showOutdatedFirmwareAlert)
        }
        .alert(isPresented: $showOutdatedMobileAlert) {
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
        .onChange(of: scenePhase) { scenePhase in
            switch scenePhase {
            case .active: onActive()
            default: break
            }
        }
        .task {
            if central.state != .poweredOn {
                central.kick()
            }
            suggestNotifications()
        }
        .alert(isPresented: $showNotificationsAlert) {
            EnableNotificationsAlert(isPresented: $showNotificationsAlert) {
                Task { await enableNotifications() }
            }
        }
        .notification(isPresented: inApp.notifications.showEnabled) {
            NotificationsEnabledBanner(
                isPresented: inApp.notifications.showEnabled)
        }
        .notification(isPresented: inApp.notifications.showDisabled) {
            NotificationsDisabledBanner(
                isPresented: inApp.notifications.showDisabled)
        }
        .sheet(isPresented: $showRemoteControl) {
            RemoteControlView()
                .environmentObject(device)
        }
        .environment(\.path, $path)
    }

    func suggestNotifications() {
        guard !notificationsSuggested else { return }
        Task { @MainActor in
            try? await Task.sleep(seconds: 1)
            notificationsSuggested = true
            showNotificationsAlert = true
        }
    }

    func onActive() {
        if device.status == .disconnected, central.state == .poweredOn {
            device.connect()
        }
    }

    func connect() {
        guard device.status != .noDevice else {
            router.showWelcomeScreen()
            return
        }

        guard central.state == .poweredOn else {
            showBluetoothDisabled()
            return
        }

        device.connect()
    }

    func disconnect() {
        device.disconnect()
    }

    func enableNotifications() async {
        do {
            try await notifications.enable()
            isNotificationsOn = true
            inApp.notifications.showEnabled = true
        } catch {
            inApp.notifications.showDisabled = true
        }
    }
}

// FIXME: refactor

import CoreBluetooth

private func showBluetoothDisabled() {
    _ = CBCentralManager()
}
