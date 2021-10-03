import Core
import Combine
import Injector

class StorageViewModel: ObservableObject {
    @Inject var connector: BluetoothConnector
    @Published var elements: [Element]

    var root: [Element] = [.directory("int"), .directory("ext")]
    var path: [Directory] = []

    private var disposeBag: DisposeBag = .init()

    var device: BluetoothPeripheral? {
        didSet { subscribeToUpdates() }
    }

    init() {
        elements = root
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

    func moveUp() {
        guard !path.isEmpty else {
            return
        }
        elements.removeAll()
        path.removeLast()
        if path.isEmpty {
            elements = root
        } else {
            device?.send(.list(path))
        }
    }

    func listDirectory(_ name: String) {
        elements.removeAll()
        path.append(.init(name: name))
        device?.send(.list(path))
    }
}
