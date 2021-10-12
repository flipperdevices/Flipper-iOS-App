import Core
import Combine
import Injector

class StorageViewModel: ObservableObject {
    @Inject var connector: BluetoothConnector
    @Published var content: Content?

    var supportedExtensions: [String] = [
        ".ibtn", ".nfc", ".sub", ".rfid", ".ir"
    ]

    enum Content {
        case list([Element])
        case data([UInt8])
    }

    var root: [Element] = [.directory("int"), .directory("ext")]
    var path: [Directory] = []

    var title: String {
        path.isEmpty
            ? "Storage browser"
            : path.reduce(into: "") { $0.append("/" + $1.name) }
    }

    private var disposeBag: DisposeBag = .init()

    var device: BluetoothPeripheral? {
        didSet { subscribeToUpdates() }
    }

    init() {
        content = .list(root)
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
                self.handleResponse(response)
            }
            .store(in: &disposeBag)
    }

    func handleResponse(_ response: Response) {
        switch response {
        case .list(let files):
            self.content = .list(files)
        case .file(let bytes):
            self.content = .data(bytes)
        default:
            print("error")
        }
    }

    func moveUp() {
        guard !path.isEmpty else {
            return
        }
        content = nil
        path.removeLast()
        if path.isEmpty {
            content = .list(root)
        } else {
            device?.send(.list(path))
        }
    }

    func listDirectory(_ name: String) {
        content = nil
        path.append(.init(name: name))
        device?.send(.list(path))
    }

    func canRead(_ file: File) -> Bool {
        supportedExtensions.contains {
            file.name.hasSuffix($0)
        }
    }

    func readFile(_ file: File) {
        content = nil
        path.append(.init(name: file.name))
        device?.send(.read(path))
    }
}
