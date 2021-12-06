class FlipperArchive: PeripheralArchive {
    let root: Path = .init(components: ["ext"])
    private let rpc: RPC = .shared

    var directories: [Path] {
        ArchiveItem.FileType.allCases.map {
            root.appending($0.directory)
        }
    }

    init() {}

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

    func write(_ item: ArchiveItem, at path: Path) async throws {
        let bytes = [UInt8](item.content.utf8)
        try await rpc.writeFile(at: path, bytes: bytes, priority: .background)
    }

    func delete(at path: Path) async throws {
        try await rpc.deleteFile(at: path, force: false, priority: .background)
    }

    func getFileHash(at path: Path) async throws -> Hash {
        .init(try await rpc.calculateFileHash(at: path, priority: .background))
    }
}

fileprivate extension ArchiveItem {
    init?(at path: Path, content: String) {
        guard let fileName = path.components.last else {
            return nil
        }
        self.init(fileName: fileName, content: content, status: .imported)
    }
}
