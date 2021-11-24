public class FlipperArchive {
    public static let shared: FlipperArchive = .init()

    private let root: Path = .init(components: ["ext"])
    private let rpc: RPC = .shared

    private init() {}

    public func readAllItems() async throws -> [ArchiveItem] {
        let paths = try await listAllFiles()
        return try await self.readFiles(paths)
    }

    public func listAllFiles() async throws -> [Path] {
        let supportedPaths: [Path] = ArchiveItem.FileType.allCases.map {
            root.appending($0.directory)
        }

        var archiveFiles: [Path] = .init()

        for path in supportedPaths {
            let elements = try await rpc.listDirectory(
                at: path,
                priority: .background)
            let filePaths = elements.files.map { path.appending($0) }
            archiveFiles.append(contentsOf: filePaths)
        }

        return archiveFiles
    }

    public func readFile(at path: Path) async throws -> String {
        let bytes = try await rpc.readFile(at: path, priority: .background)
        return String(decoding: bytes, as: UTF8.self)
    }

    public func delete(_ item: ArchiveItem) async throws {
        try await rpc.deleteFile(at: item.path, force: false)
    }

    public func writeKey(_ content: String, at path: Path) async throws {
        try await rpc.writeFile(at: path, bytes: [UInt8](content.utf8))
    }

    private func readFiles(_ paths: [Path]) async throws -> [ArchiveItem] {
        var items: [ArchiveItem] = []

        for path in paths {
            let content = try await readFile(at: path)
            if let next = ArchiveItem(
                fileName: path.components.last ?? "",
                content: content,
                status: .synchronizied
            ) {
                items.append(next)
            }
        }

        return items
    }

    func getFileHashes(at paths: [Path]) async throws -> [String] {
        var items: [String] = []

        for path in paths {
            let content = try await getFileHash(at: path)
            items.append(content)
        }

        return items
    }

    func getFileHash(at path: Path) async throws -> String {
        return try await rpc.calculateFileHash(at: path, priority: .background)
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
