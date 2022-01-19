import Inject
import Combine
import Dispatch
import Foundation

public class AppState {
    public static let shared: AppState = .init()

    public var isFirstLaunch: Bool {
        get { UserDefaultsStorage.shared.isFirstLaunch }
        set { UserDefaultsStorage.shared.isFirstLaunch = newValue }
    }

    @Inject private var pairedDevice: PairedDevice
    private var disposeBag: DisposeBag = .init()

    @Published public var device: Peripheral?
    @Published public var capabilities: Capabilities?
    @Published public var archive: Archive = .shared
    @Published public var status: Status = .noDevice {
        didSet { measureSyncTime() }
    }

    public init() {
        pairedDevice.peripheral
            .receive(on: DispatchQueue.main)
            .sink { [weak self] device in
                self?.device = device
                self?.capabilities = .init(device?.protobufVersion)
                self?.updateState(device?.state)
            }
            .store(in: &disposeBag)
    }

    // MARK: Status

    var connectAttemptCount = 0
    let connectAttemptCountMax = 3

    // swiftlint:disable cyclomatic_complexity
    func updateState(_ newValue: Peripheral.State?) {
        guard let newValue = newValue else {
            status = .noDevice
            return
        }
        switch status {
        // MARK: Pairing
        case .pairing where device?.battery != nil: didConnect()
        case .noDevice where newValue == .connecting: status = .preParing
        case .preParing where newValue == .connected: status = .pairing
        case .preParing where newValue == .disconnected: didFailToConnect()
        case _ where pairedDevice.isPairingFailed: pairedDevice.forget()
        // MARK: Default
        case .connecting where newValue == .connected: didConnect()
        case .connecting where newValue == .disconnected: didFailToConnect()
        case .connected where newValue == .disconnected: didDisconnect()
        case .synchronizing where newValue == .disconnected: didDisconnect()
        default: status = .init(newValue)
        }
    }

    func didConnect() {
        status = .connected
        connectAttemptCount = 0
        Task {
            await getStorageInfo()
            await synchronizeDateTime()
            await synchronize()
        }
    }

    func didDisconnect() {
        status = .disconnected
        guard !pairedDevice.isPairingFailed else {
            return
        }
        connect()
    }

    func didFailToConnect() {
        status = .disconnected
        guard connectAttemptCount >= connectAttemptCountMax else {
            connectAttemptCount += 1
            connect()
            return
        }
        status = .pairingIssue
    }

    // MARK: Connection

    public func connect() {
        pairedDevice.connect()
    }

    public func disconnect() {
        pairedDevice.disconnect()
    }

    public func forgetDevice() {
        pairedDevice.forget()
    }

    // MARK: Synchronization

    public func synchronize() async {
        guard status == .connected else { return }
        status = .synchronizing
        await archive.syncWithDevice()
        status = .init(device?.state)
    }

    func synchronizeDateTime() async {
        guard status == .connected else { return }
        status = .synchronizing
        try? await RPC.shared.setDate()
        status = .init(device?.state)
    }

    func getStorageInfo() async {
        var storage = device?.storage ?? .init()
        if let intSpace = try? await RPC.shared.getStorageInfo(at: "/int") {
            storage.internal = intSpace
        }
        if let extSpace = try? await RPC.shared.getStorageInfo(at: "/ext") {
            storage.external = extSpace
        }
        device?.storage = storage
    }

    // MARK: Debug

    var start: Date?

    func measureSyncTime() {
        switch status {
        case .synchronizing:
            start = .init()
        case .connected where start != nil:
            // swiftlint:disable force_unwrapping
            print(Date().timeIntervalSince(start!))
            start = nil
        default:
            break
        }
    }

    // MARK: App Reset

    // FIXME: Find a better way

    @Inject var archiveStorage: ArchiveStorage
    @Inject var deviceStorage: DeviceStorage
    @Inject var manifestStorage: ManifestStorage

    public func reset() {
        isFirstLaunch = true
        archiveStorage.items = []
        deviceStorage.pairedDevice = nil
        manifestStorage.manifest = nil
        UserDefaults.standard.removeObject(forKey: "selectedTab")
        exit(0)
    }
}
