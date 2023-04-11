import Peripheral

import Combine
import Foundation

@MainActor
public class Device: ObservableObject {
    @Published public var status: Status = .noDevice

    private var pairedDevice: PairedDevice
    private var rpc: RPC { pairedDevice.session }
    private var cancellables = [AnyCancellable]()

    @Published public var isLocked = false

    @Published public var flipper: Flipper?
    @Published public private(set) var frame: ScreenFrame?

    @Published public private(set) var info: Info = .init()
    @Published public private(set) var isInfoReady = false

    public init(pairedDevice: PairedDevice) {
        self.pairedDevice = pairedDevice
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
            .store(in: &cancellables)

        rpc.onScreenFrame = { [weak self] frame in
            guard let self else { return }
            Task { @MainActor in
                self.frame = frame
            }
        }
    }

    // MARK: Device Events

    func onFlipperChanged(_ oldValue: Flipper?) {
        updateState(oldValue?.state ?? .disconnected)
        if oldValue?.information != flipper?.information {
            reportGATTInfo()
        }
    }

    // MARK: Status

    func updateState(_ oldValue: FlipperState) {
        guard let flipper = flipper else {
            status = .noDevice
            return
        }
        guard flipper.state != oldValue else {
            return
        }

        // We want to preserve unsupportedDevice state instead of disconnected
        if
            (status == .unsupported || status == .outdatedMobile),
            flipper.state == .disconnected
        {
            return
        }

        // We want to preserve updating state instead of disconnected/connecting
        if status == .updating {
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
        default: status = .init(flipper.state)
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
                status = .connected
                logger.info("connected")
                try await updateStorageInfo()
            } catch {
                logger.error("did connect: \(error)")
            }
        }
    }

    // MARK: Disconnect event

    var reconnectOnDisconnect = true

    func didDisconnect() {
        logger.info("disconnected")
        status = .disconnected
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
            status = .disconnected
            return false
        }
        guard version >= .v0_6 else {
            logger.error("unsupported firmware version")
            status = .unsupported
            return false
        }
        guard version < .v1_0 else {
            logger.error("outdated mobile app version")
            status = .outdatedMobile
            return false
        }
        return true
    }

    // MARK: Connection

    public func connect() {
        logger.info("connecting")
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

    public func pressButton(_ button: InputKey) async throws {
        do {
            try await rpc.pressButton(button)
        } catch {
            logger.error("press button: \(error)")
            throw error
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
        status = .updating
        logger.info("update started")
    }

    public func getInfo() async {
        guard let version = flipper?.information?.protobufRevision else {
            return
        }
        isInfoReady = false
        if version < .v0_14 {
            await getDeviceInfo()
            await getPowerInfo()
        } else {
            await updateValues("devinfo")
            await updateValues("pwrinfo")
            await updateValues("pwrdebug")
        }
        isInfoReady = true
    }

    func updateValues(_ key: String) async {
        do {
            for try await property in rpc.property(key) {
                info.update(key: property.key, value: property.value)
            }
        } catch {
            logger.error("update values: \(error)")
        }
    }

    public func getDeviceInfo() async {
        do {
            for try await (key, value) in rpc.deviceInfo() {
                info.update(key: key, value: value)
            }
        } catch {
            logger.error("device info: \(error)")
        }
    }


    public func getRegion() async throws -> Provisioning.Region {
        let bytes = try await rpc.readFile(at: Provisioning.location)
        return try Provisioning.Region(decoding: bytes)
    }

    public func hasAssetsManifest() async throws -> Bool {
        do {
            _ = try await rpc.getSize(at: .manifest)
            return true
        } catch let error as Peripheral.Error
                    where error == .storage(.doesNotExist)
        {
            return false
        }
    }

    public func getPowerInfo() async {
        do {
            for try await (key, value) in rpc.powerInfo() {
                info.update(key: key, value: value)
            }
        } catch {
            logger.error("power info: \(error)")
        }
    }

    public var hasBatteryCharged: Bool {
        guard let battery = flipper?.battery else { return false }
        return battery.level >= 10 || battery.state == .charging
    }

    public func lock() async throws {
        // <(^_^)>
        try await rpc.pressButton(.back)
        try await rpc.pressButton(.back)
        try await rpc.pressButton(.back)
        // couldn't exit the app
        guard !(try await rpc.isLocked) else {
            return
        }
        try await rpc.pressButton(.up)
        try await rpc.pressButton(.enter)
        // FIXME: updateLockStatus
        self.isLocked = true
    }

    public func unlock() async throws {
        // <(^_^)>
        try await rpc.pressButton(.back)
        try await rpc.pressButton(.back)
        try await rpc.pressButton(.back)
        // FIXME: updateLockStatus
        self.isLocked = false
    }

    public func updateLockStatus() {
        Task { @MainActor in
            do {
                // FIXME: acts like isApplicationRunning
                // self.isLocked = try await rpc.isLocked
                let isLocked = try await rpc.isLocked
                logger.debug("is locked: \(isLocked)")
            } catch {
                logger.error("update lock status: \(error)")
            }
        }
    }
}

extension Device {

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
