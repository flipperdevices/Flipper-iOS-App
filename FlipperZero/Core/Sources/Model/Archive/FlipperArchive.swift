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
    fileprivate var path: Path {
        .init(components: ["any", fileType.directory, fileName])
    }
}
