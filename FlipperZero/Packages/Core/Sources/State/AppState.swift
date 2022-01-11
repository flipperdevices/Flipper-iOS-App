import Inject
import Combine
import Dispatch

public class AppState {
    public static let shared: AppState = .init()

    @Inject private var pairedDevice: PairedDevice
    private var disposeBag: DisposeBag = .init()

    @Published public var device: Peripheral?
    @Published public var archive: Archive = .shared
    @Published public var status: Status = .noDevice {
        didSet {
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
}
