public class FlipperArchive {
    public static let shared: FlipperArchive = .init()

    private let root: Path = .init(components: ["any"])
    private let rpc: RPC = .shared

    private init() {}

    public func readAllItems(
        _ completion: @escaping (Result<[ArchiveItem], Error>) -> Void
    ) {
        listAllFiles { [weak self] result in
            switch result {
            case .success(let files):
                self?.readFiles(files, completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    public func listAllFiles(
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

    public func readFile(
        at path: Path,
        _ completion: @escaping (Result<String, Error>) -> Void
    ) {
        rpc.readFile(at: path, priority: .background) { result in
            switch result {
            case .success(let bytes):
                completion(.success(String(decoding: bytes, as: UTF8.self)))
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
        _ content: String,
        at path: Path,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        rpc.writeFile(at: path, bytes: [UInt8](content.utf8)) { response in
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
            readFile(at: path) { result in
                switch result {
                case .success(let content):
                    if let next = ArchiveItem(
                        fileName: path.components.last ?? "",
                        content: content,
                        status: .synchronizied
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
