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

    var device: BluetoothPeripheral?

    init() {
        content = .list(root)
        connector.connectedPeripherals
            .sink { [weak self] in
                self?.device = $0.first
            }
            .store(in: &disposeBag)
    }

    // MARK: Directory

    func moveUp() {
        guard !path.isEmpty else {
            return
        }
        content = nil
        path.removeLast()
        if path.isEmpty {
            content = .list(root)
        } else {
            sendListRequest()
        }
    }

    func listDirectory(_ name: String) {
        content = nil
        path.append(.init(name: name))
        sendListRequest()
    }

    private func sendListRequest() {
        device?.send(.list(path)) { response in
            guard case .list(let files) = response else {
                print("invalid response", response)
                return
            }
            self.content = .list(files)
        }
    }

    // MARK: File

    func canRead(_ file: File) -> Bool {
        supportedExtensions.contains {
            file.name.hasSuffix($0)
        }
    }

    func readFile(_ file: File) {
        content = nil
        path.append(.init(name: file.name))
        device?.send(.read(path)) { response in
            guard case .file(let bytes) = response else {
                print("invalid response", response)
                return
            }
            self.content = .data(bytes)
        }
    }
}
