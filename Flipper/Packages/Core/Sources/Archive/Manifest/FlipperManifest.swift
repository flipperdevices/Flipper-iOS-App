import Peripheral
// MARK: Manifest shims

// TODO: use manifest api when available

extension RPC {
    private var root: Path { .init(components: ["any"]) }

    public var manifest: Manifest {
        get async throws {
            var items = [Path: Hash]()

            try await createDirectories()

            for path in try await listAllFiles() {
                items[path] = try await getFileHash(at: path)
            }

            return .init(items)
        }
    }

    private func createDirectories() async throws {
        let list = try await listDirectory(at: root).map { $0.name }

        let missing = FileType.allCases.filter {
            !list.contains($0.location)
        }.map {
            root.appending($0.location)
        }

        for path in missing {
            try await createDirectory(at: path)
        }
    }

    private func listAllFiles() async throws -> [Path] {
        var result: [Path] = .init()

        for type in FileType.allCases {
            let path = root.appending(type.location)

            let files = try await list(at: path)
                .files
                .filter { $0.hasSuffix(type.extension) }
                .map { path.appending($0) }

            result.append(contentsOf: files)
        }

        return result
    }

    private func list(at path: Path) async throws -> [Element] {
        try await listDirectory(at: path)
    }

    private func getFileHash(at path: Path) async throws -> Hash {
        try await calculateFileHash(at: path)
    }
}

// MARK: Filter

fileprivate extension Array where Element == Peripheral.Element {
    var files: [String] {
        self.compactMap {
            guard case .file(let file) = $0 else {
                return nil
            }
            return file.name
        }
    }
}
