import Peripheral

class FlipperFileListing: FileListing {
    let storage: StorageAPI

    init(storage: StorageAPI) {
        self.storage = storage
    }

    func list(
        at path: Path,
        calculatingMD5: Bool,
        sizeLimit: Int
    ) async throws -> [Element] {
        let list = try await storage.list(
            at: path,
            calculatingMD5: calculatingMD5,
            sizeLimit: sizeLimit)

        if calculatingMD5, containsEmptyHash(list) {
            // get hash & filter by size for older firmware
            return try await addHash(for: list, at: path, sizeLimit: sizeLimit)
        } else {
            return list
        }
    }

    private func containsEmptyHash(_ elements: [Element]) -> Bool {
        !elements.files.isEmpty && elements.files[0].md5.isEmpty
    }

    private func addHash(
        for elements: [Element],
        at path: Path,
        sizeLimit: Int
    ) async throws -> [Element] {
        var result: [Element] = []

        for item in elements {
            switch item {
            case .directory:
                result.append(item)
            case .file(let file):
                guard sizeLimit == 0 || file.size <= sizeLimit else {
                    continue
                }
                let hash = try await storage.hash(of: path.appending(file.name))
                result.append(.file(.init(
                    name: file.name,
                    size: file.size,
                    data: file.data,
                    md5: hash.value)))
            }
        }

        return result
    }
}
