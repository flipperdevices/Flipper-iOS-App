class FlipperArchive: PeripheralArchive {
    private let root: Path = .init(components: ["ext"])
    private let rpc: RPC = .shared

    private var directories: [Path] {
        ArchiveItem.FileType.allCases.map {
            root.appending($0.directory)
        }
    }

    init() {}

    // TODO: use manifest api when available
    func getManifest() async throws -> Manifest {
        var items = [Manifest.Item]()

        for path in try await listAllFiles() {
            let hash = try await getFileHash(at: path)
            items.append(.init(path: path, hash: hash))
        }

        return .init(items: items)
    }

    func list(at path: Path) async throws -> [Element] {
        try await rpc.listDirectory(
            at: path,
            priority: .background)
    }

    func read(at path: Path) async throws -> ArchiveItem? {
        let bytes = try await rpc.readFile(at: path, priority: .background)
        let content = String(decoding: bytes, as: UTF8.self)
        return .init(at: path, content: content)
    }

    func write(_ item: ArchiveItem) async throws {
        try await rpc.writeFile(
            at: item.path,
            bytes: .init(item.content.utf8),
            priority: .background)
    }

    func delete(at path: Path) async throws {
        try await rpc.deleteFile(at: path, force: false, priority: .background)
    }
}

// MARK: Manifest shims

extension FlipperArchive {
    private func listAllFiles() async throws -> [Path] {
        var result: [Path] = .init()

        for path in directories {
            result.append(contentsOf: try await list(at: path).files.map {
                path.appending($0)
            })
        }

        return result
    }

    private func getFileHash(at path: Path) async throws -> Hash {
        .init(try await rpc.calculateFileHash(at: path, priority: .background))
    }
}

// MARK: Utils

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
