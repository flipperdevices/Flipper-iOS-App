import Core
import Combine
import Injector

class StorageViewModel: ObservableObject {
    @Inject var connector: BluetoothConnector
    @Published var elements: [Element] = []

    private var disposeBag: DisposeBag = .init()

    var device: BluetoothPeripheral? {
        didSet { subscribeToUpdates() }
    }

    init() {
        connector.connectedPeripherals
            .sink { [weak self] in
                self?.device = $0.first
            }
            .store(in: &disposeBag)
    }

    func subscribeToUpdates() {
        device?.received
            .sink { [weak self] response in
                guard let self = self else { return }
                guard case .list(let elements) = response else { return }
                self.elements.append(contentsOf: elements)
            }
            .store(in: &disposeBag)
    }

    func sendListRequest(for directory: String) {
        self.elements.removeAll()
        device?.send(.list(.init(name: directory)))
    }
}
