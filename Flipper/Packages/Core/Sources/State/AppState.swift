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
        didSet { onStatusChanged(oldValue: oldValue) }
    }

    public init() {
        pairedDevice.peripheral
            .receive(on: DispatchQueue.main)
            .sink { [weak self] device in
                self?.device = device
                self?.status = .init(device?.state)
                self?.capabilities = .init(device?.protobufVersion)
            }
            .store(in: &disposeBag)

        archive.$isSynchronizing
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isSynchronizing in
                self?.status = isSynchronizing
                    ? .synchronizing
                    : .init(self?.device?.state)
            }
            .store(in: &disposeBag)
    }

    // MARK: Status

    var connectAttemptCount = 0
    let connectAttemptCountMax = 3

    func onStatusChanged(oldValue: Status) {
        switch oldValue {
        case .connecting:
            switch status {
            case .connected: didConnect()
            case .disconnected: didFailPairing()
            default: break
            }
        default:
            switch status {
            case .disconnected: connect()
            default: break
            }
        }
    }

    func didConnect() {
        connectAttemptCount = 0
        Task {
            await getStorageInfo()
            await synchronizeDateTime()
            await synchronize()
        }
    }

    func didFailPairing() {
        guard connectAttemptCount >= connectAttemptCountMax else {
            connectAttemptCount += 1
            connect()
            return
        }
        self.status = .pairingIssue
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
