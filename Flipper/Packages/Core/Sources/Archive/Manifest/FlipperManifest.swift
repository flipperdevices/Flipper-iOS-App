import Peripheral
// MARK: Manifest shims

// TODO: use manifest api when available

extension StorageAPI {
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
        let list = try await list(at: root).map { $0.name }

        let missing = FileType.allCases.filter {
            !list.contains($0.location)
        }.map {
            root.appending($0.location)
        }

        for path in Set(missing) {
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
                .filter { !$0.name.hasPrefix(".") }
                .filter { $0.name.hasSuffix(type.extension) }
                .map { path.appending($0.name) }

            result.append(contentsOf: files)

            progress(Double(index + 1) / Double(FileType.allCases.count))
        }

        return result
    }

    func getAllHashes(
        for paths: [Path],
        progress: (Double) -> Void
    ) async throws -> [Path: Hash] {
        var items = [Path: Hash]()

        progress(0)

        for (index, path) in paths.enumerated() {
            items[path] = try await hash(of: path)
            progress(Double(index + 1) / Double(paths.count))
        }

        return items
    }
}
