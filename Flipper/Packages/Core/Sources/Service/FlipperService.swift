import Inject
import Analytics
import Peripheral

import Logging
import Combine
import Foundation

@MainActor
public class FlipperService: ObservableObject {
    let appState: AppState

    @Inject var rpc: RPC
    @Inject var pairedDevice: PairedDevice
    private var disposeBag = DisposeBag()

    @Published public var flipper: Flipper?
    @Published public private(set) var frame: ScreenFrame = .init()

    @Published public private(set) var deviceInfo: [String: String] = [:]
    @Published public private(set) var powerInfo: [String: String] = [:]
    @Published public private(set) var isInfoReady = false

    public init(appState: AppState) {
        self.appState = appState
        subscribeToPublishers()
    }

    private func subscribeToPublishers() {
        pairedDevice.flipper
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newValue in
                guard let self else { return }
                let oldValue = self.flipper
                self.flipper = newValue
                self.onFlipperChanged(oldValue)
            }
            .store(in: &disposeBag)

        rpc.onScreenFrame { [weak self] frame in
            guard let self else { return }
            Task { @MainActor in
                self.frame = frame
            }
        }
    }

    // MARK: Device Events

    func onFlipperChanged(_ oldValue: Flipper?) {
        updateState(oldValue?.state)
        if oldValue?.information != flipper?.information {
            reportGATTInfo()
        }
    }

    // MARK: Status

    func updateState(_ oldValue: FlipperState?) {
        guard let flipper = flipper else {
            appState.status = .noDevice
            return
        }
        guard flipper.state != oldValue else {
            return
        }

        // We want to preserve unsupportedDevice state instead of disconnected
        if
            appState.status == .unsupported &&
            flipper.state == .disconnected
        {
            return
        }

        // We want to preserve updating state instead of disconnected/connecting
        if appState.status == .updating {
            if flipper.state == .disconnected {
                connect()
                return
            } else if flipper.state == .connecting {
                return
            }
        }

        switch flipper.state {
        case .connected: didConnect()
        case .disconnected: didDisconnect()
        default: appState.status = .init(flipper.state)
        }
    }

    func didConnect() {
        Task {
            do {
                try await waitForProtobufVersion()
                guard validateFirmwareVersion() else {
                    disconnect()
                    return
                }
                try await updateStorageInfo()
                appState.status = .connected
                logger.info("connected")
            } catch {
                logger.error("did connect: \(error)")
            }
        }
    }

    // MARK: Disconnect event

    var reconnectOnDisconnect = true

    func didDisconnect() {
        logger.info("disconnected")
        appState.status = .disconnected
        guard reconnectOnDisconnect else {
            return
        }
        logger.debug("reconnecting")
        connect()
    }

    func waitForProtobufVersion() async throws {
        while true {
            try await Task.sleep(nanoseconds: 100 * 1_000_000)

            guard flipper?.hasProtobufVersion != nil else { continue }
            guard flipper?.hasProtobufVersion == true else { return }

            guard let info = flipper?.information else { continue }
            guard info.protobufRevision != .unknown else { continue }

            return
        }
    }

    func validateFirmwareVersion() -> Bool {
        guard let version = flipper?.information?.protobufRevision else {
            logger.error("can't validate firmware version")
            appState.status = .disconnected
            return false
        }
        guard version >= .v0_6 else {
            logger.error("unsupported firmware version")
            appState.status = .unsupported
            return false
        }
        return true
    }

    // MARK: Connection

    public func connect() {
        reconnectOnDisconnect = true
        pairedDevice.connect()
    }

    public func disconnect() {
        reconnectOnDisconnect = false
        pairedDevice.disconnect()
    }

    public func forgetDevice() {
        pairedDevice.forget()
    }

    // MARK: API

    public func updateStorageInfo() async throws {
        var storageInfo = Flipper.StorageInfo()
        defer {
            pairedDevice.updateStorageInfo(storageInfo)
            reportRPCInfo()
        }
        do {
            storageInfo.internal = try await rpc.getStorageInfo(at: "/int")
            storageInfo.external = try await rpc.getStorageInfo(at: "/ext")
        } catch {
            logger.error("updating storage info")
            throw error
        }
    }

    public func startScreenStreaming() {
        Task {
            do {
                try await rpc.startStreaming()
            } catch {
                logger.error("start streaming: \(error)")
            }
        }
        recordRemoteControl()
    }

    public func stopScreenStreaming() {
        Task {
            do {
                try await rpc.stopStreaming()
            } catch {
                logger.error("stop streaming: \(error)")
            }
        }
    }

    public func pressButton(_ button: InputKey) {
        Task {
            do {
                try await rpc.pressButton(button)
            } catch {
                logger.error("press button: \(error)")
            }
        }
    }

    public func playAlert() {
        Task {
            do {
                try await rpc.playAlert()
            } catch {
                logger.error("play alert intent: \(error)")
            }
        }
    }

    public func reboot() {
        Task {
            do {
                try await rpc.reboot(to: .os)
            } catch {
                logger.error("reboot flipper: \(error)")
            }
        }
    }

    private var isProvisioningDisabled: Bool {
        get {
            UserDefaultsStorage.shared.isProvisioningDisabled
        }
    }

    private var hardwareRegion: Int? {
        get async throws {
            let info = try await rpc.deviceInfo()
            return Int(info["hardware_region"] ?? "")
        }
    }

    private var canDisableProvisioning: Bool {
        get async {
            (try? await hardwareRegion) == 0
        }
    }

    public func provideSubGHzRegion() async throws {
        if isProvisioningDisabled, await canDisableProvisioning {
            return
        }
        try await rpc.writeFile(
            at: Provisioning.location,
            bytes: Provisioning().provideRegion().encode())
    }

    public func showUpdatingFrame() async throws {
        try await rpc.startVirtualDisplay(with: .updateInProgress)
    }

    public func hideUpdatingFrame() async throws {
        try await rpc.stopVirtualDisplay()
    }

    public func startUpdateProcess(from path: Path) async throws {
        try await rpc.update(manifest: path.appending("update.fuf"))
        try await rpc.reboot(to: .update)
        logger.info("update started")
    }

    public func getInfo() async {
        isInfoReady = false
        await getDeviceInfo()
        await getPowerInfo()
        isInfoReady = true
    }

    public func getDeviceInfo() async {
        do {
            for try await (key, value) in rpc.deviceInfo() {
                deviceInfo[key] = value
            }
        } catch {
            logger.error("device info: \(error)")
        }
    }

    public func getPowerInfo() async {
        do {
            for try await (key, value) in rpc.powerInfo() {
                powerInfo[key] = value
            }
        } catch {
            logger.error("power info: \(error)")
        }
    }
}

extension FlipperService {

    // MARK: Analytics

    func reportGATTInfo() {
        analytics.flipperGATTInfo(
            flipperVersion: flipper?.information?.softwareRevision ?? "unknown")
    }

    func reportRPCInfo() {
        guard let storage = flipper?.storage else { return }
        analytics.flipperRPCInfo(
            sdcardIsAvailable: storage.external != nil,
            internalFreeByte: storage.internal?.free ?? 0,
            internalTotalByte: storage.internal?.total ?? 0,
            externalFreeByte: storage.external?.free ?? 0,
            externalTotalByte: storage.external?.total ?? 0)
    }

    func recordRemoteControl() {
        analytics.appOpen(target: .remoteControl)
    }
}
