import Peripheral

class FileSystemManifest {
    let listing: FileListing

    var fileSizeLimit: Int {
        10 * 1024 * 1024 // 10MiB
    }

    init(listing: FileListing) {
        self.listing = listing
    }

    func get(
        progress: (Double) -> Void
    ) async throws -> (Manifest, KnownDirectories) {
        var result: [Path: Hash] = .init()

        let rootDirectories = try await listing.list(
            at: "/",
            calculatingMD5: false,
            sizeLimit: 0
        )
        .directories

        let knownDirectories = rootDirectories
            .filter { FileType.allCases.map { $0.location }.contains($0.name) }
            .map { Path(string: $0.name) }

        let existingFFFTypes = FileType.allCases.filter { type in
            rootDirectories.contains { directory in
                directory.name == type.location
            }
        }

        guard !existingFFFTypes.isEmpty else {
            progress(1.0)
            return (.init(result), .init(knownDirectories))
        }

        for (index, type) in existingFFFTypes.enumerated() {
            let path = Path(string: type.location)

            try await listing.list(
                at: path,
                calculatingMD5: true,
                sizeLimit: fileSizeLimit
            )
            .files
            .filter { !$0.name.hasPrefix(".") }
            .filter { $0.name.hasSuffix(type.extension) }
            .forEach {
                result[path.appending($0.name)] = .init($0.md5)
            }

            progress(Double(index + 1) / Double(existingFFFTypes.count))
        }

        return (.init(result), .init(knownDirectories))
    }
}
