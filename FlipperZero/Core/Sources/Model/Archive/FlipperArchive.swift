public class FlipperArchive {
    public static let shared: FlipperArchive = .init()

    private let root: Path = .init(components: ["any"])
    private let rpc: RPC = .shared

    private init() {}

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

    public func delete(
        _ item: ArchiveItem,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        rpc.deleteFile(at: item.path, force: false, completion: completion)
    }

    public func writeKey(
        _ bytes: [UInt8],
        at path: Path,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        rpc.writeFile(at: path, bytes: bytes) { response in
            switch response {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    private func readFiles(
        _ paths: [Path],
        _ completion: @escaping (Result<[ArchiveItem], Error>) -> Void
    ) {
        var items: [ArchiveItem] = []

        for path in paths {
            rpc.readFile(at: path, priority: .background) { result in
                switch result {
                case .success(let bytes):
                    let content = String(decoding: bytes, as: UTF8.self)
                    if let next = ArchiveItem(
                        fileName: path.components.last ?? "",
                        content: content
                    ) {
                        items.append(next)
                    }
                    if path == paths.last {
                        completion(.success(items))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }

    private func listFiles(
        _ completion: @escaping (Result<[Path], Error>) -> Void
    ) {
        let supportedPaths: [Path] = ArchiveItem.FileType.allCases.map {
            root.appending($0.directory)
        }

        var archiveFiles: [Path] = .init()

        for path in supportedPaths {
            rpc.listDirectory(at: path, priority: .background) { result in
                switch result {
                case .success(let elements):
                    let filePaths = elements.files.map { path.appending($0) }
                    archiveFiles.append(contentsOf: filePaths)

                    if path == supportedPaths.last {
                        completion(.success(archiveFiles))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
}

extension Array where Element == Core.Element {
    var files: [String] {
        self.compactMap {
            guard case .file(let file) = $0 else {
                return nil
            }
            return file.name
        }
    }
}

extension ArchiveItem {
    init?(fileName: String, content: String) {
        guard let name = Name(fileName: fileName) else {
            print("invalid file name: \(fileName)")
            return nil
        }

        guard let type = FileType(fileName: fileName) else {
            print("invalid file type: \(fileName)")
            return nil
        }

        guard let properties = [Property](text: content) else {
            print("invalid content: \(content)")
            return nil
        }

        self = .init(
            id: fileName,
            name: name,
            fileType: type,
            properties: properties,
            isFavorite: false)
    }

    public var fileName: String {
        "\(name).\(fileType.extension)"
    }

    public var content: String {
        properties.reduce(into: "") { result, property in
            for line in property.description {
                result += "# \(line)\n"
            }
            result += "\(property.key): \(property.value)\n"
        }
    }
}

extension ArchiveItem.Name {
    init?<T: StringProtocol>(fileName: T) {
        guard let name = fileName.split(separator: ".").first else {
            return nil
        }
        self.value = String(name)
    }
}

extension ArchiveItem.FileType {
    init?<T: StringProtocol>(fileName: T) {
        guard let `extension` = fileName.split(separator: ".").last else {
            return nil
        }
        switch `extension` {
        case "ibtn": self = .ibutton
        case "nfc": self = .nfc
        case "sub": self = .subghz
        case "rfid": self = .rfid
        case "ir": self = .irda
        default: return nil
        }
    }

    public var `extension`: String {
        switch self {
        case .ibutton: return "ibtn"
        case .nfc: return "nfc"
        case .subghz: return "sub"
        case .rfid: return "rfid"
        case .irda: return "ir"
        }
    }

    var directory: String {
        switch self {
        case .ibutton: return "ibutton"
        case .nfc: return "nfc"
        case .subghz: return "subghz/saved"
        case .rfid: return "lfrfid"
        case .irda: return "irda"
        }
    }
}

extension ArchiveItem {
    fileprivate var path: Path {
        .init(components: ["any", fileType.directory, fileName])
    }
}

extension Array where Element == ArchiveItem.Property {
    init?(text: String) {
        var comments: [String] = []
        var properties: [ArchiveItem.Property] = []

        for line in text.split(separator: "\n") {
            guard !line.starts(with: "#") else {
                let comment = line.dropFirst()
                comments.append(comment.trimmingCharacters(in: .whitespaces))
                continue
            }
            let description = comments
            comments.removeAll()

            let parts = line.split(separator: ":", maxSplits: 1)
            guard parts.count == 2 else {
                return nil
            }
            guard let key = parts.first, let value = parts.last else {
                return nil
            }
            properties.append(.init(
                key: String(key.trimmingCharacters(in: .whitespaces)),
                value: String(value.trimmingCharacters(in: .whitespaces)),
                description: description))
        }

        self = properties
    }
}
