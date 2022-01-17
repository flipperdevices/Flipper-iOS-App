import Inject
import Combine
import Dispatch
import SwiftUI

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
        didSet {
            if oldValue == .connecting, status == .disconnected {
                self.status = .pairingIssue
                return
            }

            if oldValue == .connecting, status == .connected {
                Task {
                    await synchronizeDateTime()
                    await synchronize()
                }
            }
        }
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

    public func connect() {
    }

    public func disconnect() {
        pairedDevice.disconnect()
    }

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
