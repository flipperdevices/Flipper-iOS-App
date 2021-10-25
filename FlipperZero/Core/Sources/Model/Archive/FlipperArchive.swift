import Injector

public class FlipperArchive {
    public static let shared: FlipperArchive = .init()

    var flipper: BluetoothPeripheral?

    @Inject var connector: BluetoothConnector
    var disposeBag: DisposeBag = .init()

    private init() {
        connector.connectedPeripherals
            .sink { [weak self] peripheral in
                self?.flipper = peripheral.first
            }
            .store(in: &disposeBag)
    }

    public func readFromDevice(
        _ completion: @escaping ([ArchiveItem]) -> Void
    ) {
        var items: [ArchiveItem] = []

        listFiles { [weak self] files in
            for file in files {
                self?.readFile(path: file) { [weak self] bytes in
                    let content = String(decoding: bytes, as: UTF8.self)
                    if let next = self?.parse(path: file, content: content) {
                        items.append(next)
                    }
                    if file == files.last {
                        completion(items)
                    }
                }
            }
        }
    }

    private func listFiles(_ completion: @escaping ([String]) -> Void) {
        let paths = ["ibutton", "nfc", "lfrfid", "irda", "subghz/saved"].map {
            "/ext/\($0)"
        }
        var keyPaths: [String] = .init()

        for path in paths {
            flipper?.send(.list(.init(string: path))) { response in
                guard case .list(let items) = response else {
                    return
                }
                let filePaths = items.fileNames.map { "\(path)/\($0)" }
                keyPaths.append(contentsOf: filePaths)

                if path == paths.last {
                    completion(keyPaths)
                }
            }
        }
    }

    private func readFile(
        path: String,
        completion: @escaping ([UInt8]) -> Void
    ) {
        flipper?.send(.read(.init(string: path))) { response in
            guard case .file(let bytes) = response else {
                return
            }
            completion(bytes)
        }
    }

    private func parse(path: String, content: String) -> ArchiveItem? {
        let fileName = path.split(separator: "/").last ?? ""
        let name = String(fileName.split(separator: ".").first ?? "")
        let ext = fileName.split(separator: ".").last ?? ""

        guard let kind = ArchiveItem.Kind(ext) else {
            print("unknown extension \(ext)")
            return nil
        }

        return .init(
            id: path,
            name: name,
            description: content,
            isFavorite: false,
            kind: kind,
            origin: "ext")
    }
}

extension Array where Element == Core.Element {
    var fileNames: [String] {
        self.compactMap {
            guard case .file(let file) = $0 else {
                return nil
            }
            return file.name
        }
    }
}

extension ArchiveItem.Kind {
    init?<T: StringProtocol>(_ ext: T) {
        switch ext {
        case "ibtn": self = .ibutton
        case "nfc": self = .nfc
        case "sub": self = .subghz
        case "rfid": self = .rfid
        case "ir": self = .irda
        default: return nil
        }
    }
}
