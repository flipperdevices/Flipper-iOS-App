import Peripheral

import Combine
import Foundation

@MainActor
public class Device: ObservableObject {
    @Published public var status: Status = .noDevice

    private var central: Central
    private var pairedDevice: PairedDevice
    private var cancellables = [AnyCancellable]()

    private var system: SystemAPI
    private var storage: StorageAPI
    private var desktop: DesktopAPI
    private var gui: GUIAPI

    @Published public var isLocked = false

    @Published public var flipper: Flipper?
    @Published public var storageInfo: StorageInfo?
    @Published public private(set) var frame: ScreenFrame?

    @Published public private(set) var info: Info = .init()
    @Published public private(set) var isInfoReady = false

    public struct StorageInfo: Equatable {
        public var `internal`: StorageSpace?
        public var external: StorageSpace?
    }

    public init(
        central: Central,
        pairedDevice: PairedDevice,
        system: SystemAPI,
        storage: StorageAPI,
        desktop: DesktopAPI,
        gui: GUIAPI
    ) {
        self.central = central
        self.pairedDevice = pairedDevice
        self.system = system
        self.storage = storage
        self.desktop = desktop
        self.gui = gui

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

        Task { @MainActor in
            while !Task.isCancelled {
                for await frame in await gui.screenFrame {
                    self.frame = frame
                }
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
        guard central.state == .poweredOn else {
            status = .disconnected
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
                try await loadStorageInfo()
                reportRPCInfo()
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
        guard central.state == .poweredOn else {
            logger.info("bluetooth is not ready")
            return
        }
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

    private func loadStorageInfo() async throws {
        var storageInfo = StorageInfo()
        defer {
            self.storageInfo = storageInfo
        }
        do {
            storageInfo.internal = try await storage.space(of: "/int")
            storageInfo.external = try await storage.space(of: "/ext")
        } catch {
            logger.error("updating storage info")
            throw error
        }
    }

    public func startScreenStreaming() {
        Task {
            do {
                try await gui.startStreaming()
            } catch {
                logger.error("start streaming: \(error)")
            }
        }
        recordRemoteControl()
    }

    public func stopScreenStreaming() {
        Task {
            do {
                try await gui.stopStreaming()
            } catch {
                logger.error("stop streaming: \(error)")
            }
        }
    }

    public func pressButton(_ button: InputKey, isLong: Bool) async throws {
        do {
            try await gui.pressButton(button, isLong: isLong)
        } catch {
            logger.error("press button: \(error)")
            throw error
        }
    }

    public func playAlert() {
        Task {
            do {
                try await gui.playAlert()
            } catch {
                logger.error("play alert intent: \(error)")
            }
        }
    }

    public func restartSession() {
        guard let info = flipper?.information else {
            return
        }
        if info.protobufRevision >= .v0_13 {
            pairedDevice.restartSession()
        } else {
            pairedDevice.disconnect()
            pairedDevice.connect()
        }
    }

    public func reboot() {
        Task {
            do {
                try await system.reboot(to: .os)
            } catch {
                logger.error("reboot flipper: \(error)")
            }
        }
    }

    private var isProvisioningDisabled: Bool {
        UserDefaultsStorage.shared.isProvisioningDisabled
    }

    private var hardwareRegion: Int? {
        get async throws {
            let info = try await system.deviceInfo().drain()
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
        try await storage.write(
            at: Provisioning.location,
            bytes: Provisioning().provideRegion().encode()
        ).drain()
    }

    public func showUpdatingFrame() async throws {
        try await gui.startVirtualDisplay(with: .updateInProgress)
    }

    public func hideUpdatingFrame() async throws {
        try await gui.stopVirtualDisplay()
    }

    public func startUpdateProcess(from path: Path) async throws {
        try await system.update(manifest: path.appending("update.fuf"))
        try await system.reboot(to: .update)
        status = .updating
        logger.info("update started")
    }

    public func getInfo() async {
        guard let version = flipper?.information?.protobufRevision else {
            return
        }
        isInfoReady = false
        info = .init()
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
            for try await property in await system.property(key) {
                info.update(key: property.key, value: property.value)
            }
        } catch {
            logger.error("update values: \(error)")
        }
    }

    public func getDeviceInfo() async {
        do {
            for try await (key, value) in await system.deviceInfo() {
                info.update(key: key, value: value)
            }
        } catch {
            logger.error("device info: \(error)")
        }
    }

    public func getRegion() async throws -> Provisioning.Region {
        let bytes = try await storage.read(at: Provisioning.location).drain()
        return try Provisioning.Region(decoding: bytes)
    }

    public func hasAssetsManifest() async throws -> Bool {
        do {
            _ = try await storage.size(of: .manifest)
            return true
        } catch let error as Peripheral.Error
                    where error == .storage(.doesNotExist)
        {
            return false
        }
    }

    public func getPowerInfo() async {
        do {
            for try await (key, value) in await system.powerInfo() {
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
        throw Error.CommonError.notImplemented
    }

    public func unlock() async throws {
        guard
            let protobufRevision = flipper?.information?.protobufRevision,
            protobufRevision >= .v0_16
        else {
            throw Error.CommonError.notImplemented
        }
        try await desktop.unlock()
        updateLockStatus()
    }

    public func updateLockStatus() {
        self.isLocked = true
//        Task { @MainActor in
//            do {
//                self.isLocked = try await rpc.isDesktopLocked
//                logger.debug("is locked: \(isLocked)")
//            } catch {
//                self.isLocked = false
//                logger.error("update lock status: \(error)")
//            }
//        }
    }
}

extension Device {

    // MARK: Analytics

    func reportGATTInfo() {
        analytics.flipperGATTInfo(
            flipperVersion: flipper?.information?.softwareRevision ?? "unknown")
    }

    func reportRPCInfo() {
        Task {
            guard
                let protobufRevision = flipper?.information?.protobufRevision,
                let storage = storageInfo
            else {
                return
            }

            var firmwareForkName: String?
            var firmwareGitURL: String?

            if protobufRevision >= .v0_14 {
                firmwareForkName = try? await getFirmwareFork()
                firmwareGitURL = try? await getFirmwareGit()
            }

            analytics.flipperRPCInfo(
                sdcardIsAvailable: storage.external != nil,
                internalFreeByte: storage.internal?.free ?? 0,
                internalTotalByte: storage.internal?.total ?? 0,
                externalFreeByte: storage.external?.free ?? 0,
                externalTotalByte: storage.external?.total ?? 0,
                firmwareForkName: firmwareForkName ?? "",
                firmwareGitURL: firmwareGitURL ?? ""
            )
        }
    }

    func recordRemoteControl() {
        analytics.appOpen(target: .remoteControl)
    }
}

fileprivate extension Device {
    private func getFirmwareFork() async throws -> String {
        try await getProperty("devinfo.firmware.origin.fork")
    }

    private func getFirmwareGit() async throws -> String {
        try await getProperty("devinfo.firmware.origin.git")
    }

    // TODO: Move to SystemAPI extension
    private func getProperty(_ path: String) async throws -> String {
        for try await property in await system.property(path) {
            return property.value
        }
        return ""
    }
}
