import Inject
import Analytics
import Peripheral
import Foundation
import Combine
import Logging

public class AppState {
    public static let shared: AppState = .init()
    private let logger = Logger(label: "appstate")

    @Published public var isFirstLaunch: Bool {
        didSet { UserDefaultsStorage.shared.isFirstLaunch = isFirstLaunch }
    }

    @Inject private var rpc: RPC
    @Inject private var analytics: Analytics
    @Inject private var pairedDevice: PairedDevice
    private var disposeBag: DisposeBag = .init()

    @Published public var flipper: Flipper? {
        didSet { onFlipperChanged(oldValue) }
    }
    @Published public var archive: Archive = .shared
    @Published public var status: DeviceStatus = .noDevice
    @Published public var syncProgress: Int = 0

    @Published public var importQueue: [ArchiveItem] = []
    @Published public var customFirmwareURL: URL?

    @Published public var hasMFLog = false

    public init() {
        logger.info("app version: \(Bundle.fullVersion)")
        logger.info("log level: \(UserDefaultsStorage.shared.logLevel)")

        isFirstLaunch = UserDefaultsStorage.shared.isFirstLaunch

        pairedDevice.flipper
            .receive(on: DispatchQueue.main)
            .assign(to: \.flipper, on: self)
            .store(in: &disposeBag)
    }

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

    var reconnectOnDisconnect = true

    func didDisconnect() {
        logger.info("disconnected")
        guard reconnectOnDisconnect else {
            return
        }
        logger.debug("reconnecting")
        connect()
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

    // MARK: Synchronization

    public func synchronize() async throws {
        try await checkMFLogFile()
        try await syncronizeArchive()
    }

    private func checkMFLogFile() async throws {
        hasMFLog = try await rpc.fileExists(at: .mfKey32Log)
    }

    private func syncronizeArchive() async throws {
        guard flipper?.state == .connected else { return }
        guard status != .unsupportedDevice else { return }
        guard status != .synchronizing else { return }
        status = .synchronizing
        let time = try await measure {
            try await archive.synchronize { progress in
                // FIXME: find the issue (very rare)
                guard progress.isNormal else { return }
                self.syncProgress = Int(progress * 100)
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

    public func onOpenURL(_ url: URL) async {
        do {
            guard url != .widgetSettings else {
                return
            }
            switch url.pathExtension {
            case "tgz": try await onOpenUpdateBundle(url)
            default: try await onOpenKeyURL(url)
            }
        } catch {
            logger.error("open url: \(error)")
        }
    }

    private func onOpenUpdateBundle(_ url: URL) async throws {
        customFirmwareURL = url
    }

    private func onOpenKeyURL(_ url: URL) async throws {
        let item = try await Sharing.importKey(from: url)
        let newItem = try await archive.copyIfExists(item)
        importQueue = [newItem]
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
        analytics.syncronizationResult(
            subGHzCount: archive.items.count { $0.kind == .subghz },
            rfidCount: archive.items.count { $0.kind == .rfid },
            nfcCount: archive.items.count { $0.kind == .nfc },
            infraredCount: archive.items.count { $0.kind == .infrared },
            iButtonCount: archive.items.count { $0.kind == .ibutton },
            synchronizationTime: time)
    }
}

extension Array where Element == ArchiveItem {
    func count(_ isIncluded: (Self.Element) -> Bool) -> Int {
        filter(isIncluded).count
    }
}
