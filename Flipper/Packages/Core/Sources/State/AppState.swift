import Inject
import Analytics
import Peripheral
import Foundation
import Combine
import Logging

@MainActor
public class AppState: ObservableObject {
    private let logger = Logger(label: "appstate")

    @Inject private var rpc: RPC
    @Inject private var archive: Archive
    @Inject private var central: BluetoothCentral
    @Inject private var pairedDevice: PairedDevice

    @Inject public var analytics: Analytics
    private var disposeBag: DisposeBag = .init()

    @Published public var firstLaunch: FirstLaunch = .shared

    @Published public var flipper: Flipper? {
        didSet { onFlipperChanged(oldValue) }
    }
    @Published public var status: DeviceStatus = .noDevice
    @Published public var syncProgress: Int = 0

    @Published public var importQueue: [URL] = []
    @Published public var customFirmwareURL: URL?

    @Published public var hasMFLog = false
    @Published public var showWidgetSettings = false

    public init() {
        logger.info("app version: \(Bundle.fullVersion)")
        logger.info("log level: \(UserDefaultsStorage.shared.logLevel)")

        pairedDevice.flipper
            .receive(on: DispatchQueue.main)
            .assign(to: \.flipper, on: self)
            .store(in: &disposeBag)
    }

    // MARK: Welcome Screen

    public func pairDevice() {
        self.objectWillChange.send()
        firstLaunch.showWelcomeScreen()
    }

    public func skipPairing() {
        forgetDevice()
        firstLaunch.hideWelcomeScreen()
    }

    // MARK: Main Screen

    public func kickBluetoothCentral() {
        central.startScanForPeripherals()
        central.stopScanForPeripherals()
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
            status = .noDevice
            return
        }
        guard flipper.state != oldValue else {
            return
        }

        // We want to preserve unsupportedDevice state instead of disconnected
        if status == .unsupportedDevice && flipper.state == .disconnected {
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

        status = .init(flipper.state)
        switch status {
        case .connected: didConnect()
        case .disconnected: didDisconnect()
        default: break
        }
    }

    func didConnect() {
        status = .connected
        logger.info("connected")

        Task {
            do {
                try await waitForProtobufVersion()
                guard validateFirmwareVersion() else {
                    disconnect()
                    return
                }
                try await updateStorageInfo()
                #if !DEBUG
                try await synchronizeDateTime()
                try await synchronize()
                #endif
            } catch {
                logger.error("did connect: \(error)")
            }
        }
    }

    func waitForProtobufVersion() async throws {
        defer { status = .init(flipper?.state) }
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
            status = .unsupportedDevice
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

    // MARK: Disconnect event

    var reconnectOnDisconnect = true

    func didDisconnect() {
        logger.info("disconnected")
        guard reconnectOnDisconnect else {
            return
        }
        logger.debug("reconnecting")
        connect()
    }

    // MARK: Synchronization

    public func synchronize() async throws {
        try await checkMFLogFile()
        try await synchronizeArchive()
    }

    private func checkMFLogFile() async throws {
        guard status == .connected else { return }
        hasMFLog = try await rpc.fileExists(at: .mfKey32Log)
    }

    private func synchronizeArchive() async throws {
        guard flipper?.state == .connected else { return }
        guard status != .unsupportedDevice else { return }
        guard status != .synchronizing else { return }
        status = .synchronizing
        let time = try await measure {
            try await archive.synchronize { progress in
                // FIXME: find the issue (very rare)
                guard progress.isNormal else { return }
                Task { @MainActor in
                    self.syncProgress = Int(progress * 100)
                }
            }
        }
        reportSynchronizationResult(time: time)
        logger.info("syncing archive: (\(time)s)")
        status = .synchronized

        try await Task.sleep(nanoseconds: 3_000 * 1_000_000)
        guard status == .synchronized else { return }
        status = .init(flipper?.state)
    }

    public func cancelSync() {
        archive.cancelSync()
    }

    func synchronizeDateTime() async throws {
        let time = try await measure {
            try await rpc.setDate(.init())
        }
        logger.info("syncing date: (\(time)s)")
        status = .init(flipper?.state)
    }

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

    // MARK: Sharing

    public func onOpenURL(_ url: URL) {
        guard url != .widgetSettings else {
            showWidgetSettings = true
            return
        }
        switch url.pathExtension {
        case "tgz": onOpenUpdateBundle(url)
        default: onOpenKeyURL(url)
        }
    }

    private func onOpenUpdateBundle(_ url: URL) {
        customFirmwareURL = url
    }

    private func onOpenKeyURL(_ url: URL) {
        Task { @MainActor in
            importQueue = [url]
        }
        logger.info("key url opened")
    }

    public var imported: SafePublisher<ArchiveItem> {
        importedSubject.eraseToAnyPublisher()
    }
    private let importedSubject = SafeSubject<ArchiveItem>()

    public func importKey(_ item: ArchiveItem) async throws {
        try await archive.importKey(item)
        logger.info("key imported")
        importedSubject.send(item)
        try await synchronize()
    }

    // MARK: Update

    public func onUpdateStarted() {
        logger.info("update started")
        status = .updating
    }

    // MARK: Background

    var backgroundTask: Task<Void, Swift.Error>?

    public func onActive() {
        backgroundTask?.cancel()
        if status == .disconnected {
            connect()
        }
    }

    public func onInactive() async throws {
        backgroundTask = Task {
            try await Task.sleep(minutes: 10)
            logger.info("disconnecting due to inactivity")
            disconnect()
        }
        _ = await backgroundTask?.result
        backgroundTask = nil
    }

    // MARK: Debug

    func measure(_ task: () async throws -> Void) async rethrows -> Int {
        let start = Date()
        try await task()
        return Int(Date().timeIntervalSince(start) * 1000)
    }

    // MARK: App Reset

    public func reset() {
        AppReset().reset()
    }

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

    func reportSynchronizationResult(time: Int) {
        analytics.synchronizationResult(
            subGHzCount: archive._items.value.count { $0.kind == .subghz },
            rfidCount: archive._items.value.count { $0.kind == .rfid },
            nfcCount: archive._items.value.count { $0.kind == .nfc },
            infraredCount: archive._items.value.count { $0.kind == .infrared },
            iButtonCount: archive._items.value.count { $0.kind == .ibutton },
            synchronizationTime: time)
    }
}

extension Array where Element == ArchiveItem {
    func count(_ isIncluded: (Self.Element) -> Bool) -> Int {
        filter(isIncluded).count
    }
}
