import Inject
import Combine
import Dispatch

public class AppState {
    public static let shared: AppState = .init()

    @Inject private var pairedDevice: PairedDevice
    private var disposeBag: DisposeBag = .init()

    @Published public var status: Status = .noDevice
    @Published public var archive: Archive = .shared
    @Published public var device: Peripheral?

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
        Task {
            status = .synchronizing
            await archive.syncWithDevice()
            status = .init(device?.state)
        }
    }
}
