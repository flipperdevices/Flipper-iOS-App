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

    public func readAllItems(
        _ completion: @escaping (Result<[ArchiveItem], Error>) -> Void
    ) {
        listFiles { [weak self] result in
            switch result {
            case .success(let files):
                self?.readFiles(files, completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    public func readFiles(
        _ files: [String],
        _ completion: @escaping (Result<[ArchiveItem], Error>) -> Void
    ) {
        var items: [ArchiveItem] = []

        for file in files {
            readFile(path: file) { [weak self] result in
                switch result {
                case .success(let bytes):
                    let content = String(decoding: bytes, as: UTF8.self)
                    if let next = self?.parse(path: file, content: content) {
                        items.append(next)
                    }
                    if file == files.last {
                        completion(.success(items))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }

    private func listFiles(
        _ completion: @escaping (Result<[String], Error>) -> Void
    ) {
        let paths = ["ibutton", "nfc", "lfrfid", "irda", "subghz/saved"].map {
            "/ext/\($0)"
        }
        var keyPaths: [String] = .init()

        for path in paths {
            listDirectory(path: .init(string: path)) { result in
                switch result {
                case .success(let elements):
                    let filePaths = elements.fileNames.map { "\(path)/\($0)" }
                    keyPaths.append(contentsOf: filePaths)

                    if path == paths.last {
                        completion(.success(keyPaths))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }

    private func listDirectory(
        path: Path,
        _ completion: @escaping (Result<[Element], Error>) -> Void
    ) {
        flipper?.send(.list(path)) { result in
            switch result {
            case .success(.list(let items)):
                completion(.success(items))
            case .failure(let error):
                completion(.failure(error))
            default:
                completion(.failure(.common(.unknown)))
            }
        }
    }

    private func readFile(
        path: String,
        completion: @escaping (Result<[UInt8], Error>) -> Void
    ) {
        flipper?.send(.read(.init(string: path))) { result in
            switch result {
            case .success(.file(let bytes)):
                completion(.success(bytes))
            case .failure(let error):
                completion(.failure(error))
            default:
                completion(.failure(.common(.unknown)))
            }
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
