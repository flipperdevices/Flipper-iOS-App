import Core
import Inject
import Peripheral
import Foundation
import Combine
import Logging

@MainActor
class DeviceViewModel: ObservableObject {
    private let logger = Logger(label: "device-vm")

    @Inject private var rpc: RPC
    @Inject private var appState: AppState
    private var disposeBag: DisposeBag = .init()

    @Published var showForgetAction = false
    @Published var showUnsupportedVersionAlert = false

    @Published var flipper: Flipper?
    @Published var status: DeviceStatus = .noDevice {
        didSet {
            switch status {
            case .unsupportedDevice: showUnsupportedVersionAlert = true
            default: break
            }
        }
    }

    var canSync: Bool {
        status == .connected
    }

    var canPlayAlert: Bool {
        flipper?.state == .connected &&
        status != .unsupportedDevice
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
        status != .noDevice
    }

    init() {
        appState.$flipper
            .receive(on: DispatchQueue.main)
            .assign(to: \.flipper, on: self)
            .store(in: &disposeBag)

        appState.$status
            .receive(on: DispatchQueue.main)
            .assign(to: \.status, on: self)
            .store(in: &disposeBag)
    }

    func showWelcomeScreen() {
        appState.isFirstLaunch = true
    }

    func connect() {
        if status == .noDevice {
            showWelcomeScreen()
        } else {
            appState.connect()
        }
    }

    func disconnect() {
        appState.disconnect()
    }

    func showForgetActionSheet() {
        showForgetAction = true
    }

    func forgetFlipper() {
        appState.forgetDevice()
    }

    func sync() {
        Task {
            do {
                try await appState.synchronize()
            } catch {
                logger.error("device sync: \(error)")
            }
        }
    }

    func playAlert() {
        Task {
            do {
                try await rpc.playAlert()
            } catch {
                logger.error("device alert: \(error)")
            }
        }
    }
}
