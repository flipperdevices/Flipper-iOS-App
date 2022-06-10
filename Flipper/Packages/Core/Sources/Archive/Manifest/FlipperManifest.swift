import Peripheral
// MARK: Manifest shims

// TODO: use manifest api when available

extension RPC {
    private var root: Path { .init(components: ["any"]) }

    func getManifest(progress: (Double) -> Void) async throws -> Manifest {
        try await createDirectories()

        let paths = try await listAllFiles { listingProgress in
            progress(listingProgress / 2)
        }

        let hashes = try await getAllHashes(for: paths) { hashingProgress in
            progress(0.5 + hashingProgress / 2)
        }

        return .init(hashes)
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

    private func listAllFiles(
        progress: (Double) -> Void
    ) async throws -> [Path] {
        var result: [Path] = .init()

        progress(0)

        for (index, type) in FileType.allCases.enumerated() {
            let path = root.appending(type.location)

            let files = try await list(at: path)
                .files
                .filter { !$0.hasPrefix(".") }
                .filter { $0.hasSuffix(type.extension) }
                .map { path.appending($0) }

            result.append(contentsOf: files)

            progress(Double(index + 1) / Double(FileType.allCases.count))
        }

        return result
    }

    private func list(at path: Path) async throws -> [Element] {
        try await listDirectory(at: path)
    }

    func getAllHashes(
        for paths: [Path],
        progress: (Double) -> Void
    ) async throws -> [Path: Hash] {
        var items = [Path: Hash]()

        progress(0)

        for (index, path) in paths.enumerated() {
            items[path] = try await getFileHash(at: path)
            progress(Double(index + 1) / Double(paths.count))
        }

        return items
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
