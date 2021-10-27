import Core
import Combine
import Injector

import struct Foundation.Date

class StorageViewModel: ObservableObject {
    @Inject var connector: BluetoothConnector

    @Published var content: Content? {
        didSet {
            if case .data(let bytes) = content {
                text = .init(decoding: bytes, as: UTF8.self)
            }
        }
    }
    @Published var text: String = ""
    @Published var name: String = ""

    var supportedExtensions: [String] = [
        ".ibtn", ".nfc", ".sub", ".rfid", ".ir", ".txt"
    ]

    enum Content {
        case list([Element])
        case data([UInt8])
        case name(isDirectory: Bool)
        case error(String)
    }

    var root: [Element] = [.directory("int"), .directory("ext")]
    var path: Path = .init()

    var title: String {
        path.isEmpty
            ? "Storage browser"
            : requestTime == nil
                ? path.string
                // swiftlint:disable force_unwrapping
                : path.string + " - \(requestTime!.kindaRounded)s"
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
        path.removeLastComponent()
        if path.isEmpty {
            content = .list(root)
        } else {
            sendListRequest()
        }
    }

    func listDirectory(_ name: String) {
        content = nil
        path.append(name)
        sendListRequest()
    }

    private func sendListRequest() {
        device?.send(.list(path)) { result in
            switch result {
            case .success(.list(let files)):
                self.content = .list(files)
            case .failure(let error):
                self.content = .error(error.description)
            default:
                self.content = .error("invalid response: \(result)")
            }
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
        path.append(file.name)
        device?.send(.read(path)) { result in
            switch result {
            case .success(.file(let bytes)):
                self.content = .data(bytes)
            case .failure(let error):
                self.content = .error(error.description)
            default:
                self.content = .error("invalid response: \(result)")
            }
        }
    }

    // Temporary
    var startTime: Date = .init()
    var requestTime: Double?

    func save() {
        self.content = nil
        let bytes = [UInt8](text.utf8)
        startTime = .init()
        device?.send(.write(path, bytes)) { result in
            switch result {
            case .success(.ok):
                self.content = .data(bytes)
            case .failure(let error):
                self.content = .error(error.description)
            default:
                self.content = .error("invalid response: \(result)")
            }
        }
    }

    // Create

    func newElement(isDirectory: Bool) {
        content = .name(isDirectory: isDirectory)
    }

    func cancel() {
        content = nil
        sendListRequest()
    }

    func create() {
        guard !name.isEmpty else { return }
        guard case .name(let isDirectory) = content else {
            return
        }

        content = nil

        let path = path.appending(name)
        name = ""

        device?.send(.create(path, isDirectory: isDirectory)) { _ in
            self.sendListRequest()
        }
    }

    // Delete

    func delete(at index: Int) {
        guard case .list(var elements) = content else {
            return
        }

        let element = elements.remove(at: index)
        self.content = .list(elements)

        device?.send(.delete(path.appending(element.name))) { result in
            switch result {
            case .success(.ok):
                self.content = .list(elements)
            case .failure(let error):
                self.content = .error(error.description)
            default:
                self.content = .error("invalid response: \(result)")
            }
        }
    }
}

extension Double {
    var kindaRounded: Double {
        (self * 100).rounded() / 100
    }
}
