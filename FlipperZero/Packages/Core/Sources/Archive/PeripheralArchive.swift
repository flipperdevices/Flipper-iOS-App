protocol PeripheralArchive {
    var root: Path { get }
    var directories: [Path] { get }

    func getManifest() async throws -> Manifest
    func getFileHash(at path: Path) async throws -> Hash

    func list(at path: Path) async throws -> [Element]

    func read(at path: Path) async throws -> ArchiveItem?
    func write(_ item: ArchiveItem, at path: Path) async throws
    func delete(at path: Path) async throws
}

extension PeripheralArchive {
    func listAllFiles() async throws -> [Path] {
        var result: [Path] = .init()

        for path in directories {
            result.append(contentsOf: try await list(at: path).files.map {
                path.appending($0)
            })
        }

        return result
    }

    private func readAllFiles() async throws -> [ArchiveItem] {
        var items: [ArchiveItem] = []

        for path in try await listAllFiles() {
            guard let item = try await read(at: path) else {
                print("invalid item")
                continue
            }
            items.append(item)
        }

        return items
    }

    func getManifest() async throws -> Manifest {
        var items = [Manifest.Item]()

        for path in try await listAllFiles() {
            let hash = try await getFileHash(at: path)
            items.append(.init(path: path, hash: hash))
        }

        return .init(items: items)
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
