// MARK: Manifest shims

// TODO: use manifest api when available

extension FlipperArchive {
    private var root: Path { .init(components: ["ext"]) }

    var _manifest: Manifest {
        get async throws {
            var items = [Manifest.Item]()

            try await createDirectories()

            for path in try await listAllFiles() {
                let hash = try await getFileHash(at: path)
                items.append(.init(id: .init(path: path), hash: hash))
            }

            return .init(items: items)
        }
    }

    private var directories: [Path] {
        ArchiveItem.FileType.allCases.map {
            root.appending($0.location)
        }
    }

    private func createDirectories() async throws {
        let list = try await rpc.listDirectory(at: root).map { $0.name }

        let missing = ArchiveItem.FileType.allCases.filter {
            !list.contains($0.location)
        }.map {
            root.appending($0.location)
        }

        for path in missing {
            try await rpc.createFile(at: path, isDirectory: true)
        }
    }

    private func listAllFiles() async throws -> [Path] {
        var result: [Path] = .init()

        for path in directories {
            result.append(contentsOf: try await list(at: path).files.map {
                path.appending($0)
            })
        }

        return result
    }

    private func list(at path: Path) async throws -> [Element] {
        try await rpc.listDirectory(
            at: path,
            priority: .background)
    }

    private func getFileHash(at path: Path) async throws -> Hash {
        .init(try await rpc.calculateFileHash(at: path, priority: .background))
    }
}

// MARK: Filter

fileprivate extension Array where Element == Core.Element {
    var files: [String] {
        self.compactMap {
            guard case .file(let file) = $0 else {
                return nil
            }
            return file.name
        }
    }
}
