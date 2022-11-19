import UIKit
import Logging
import Foundation

class FileImporter: Importer {
    let logger = Logger(label: "file-importer")

    enum Error: String, Swift.Error {
        case cantOpenKey = "error opening key"
    }

    @MainActor
    func importKey(from url: URL) async throws -> ArchiveItem {
        switch try? Data(contentsOf: url) {
        case .some: return try await importLocalKey(from: url)
        case .none: return try await importCloudKey(from: url)
        }
    }
}

extension FileImporter {
    func importLocalKey(from url: URL) async throws -> ArchiveItem {
        let filename = url.lastPathComponent
        logger.debug("importing internal key: \(filename)")

        let data = try Data(contentsOf: url)
        // remove item passed from another app
        if url.path.starts(with: "/private") {
            try FileManager.default.removeItem(at: url)
        }
        return try .init(filename: filename, data: data)
    }
}

extension FileImporter {
    @MainActor
    func importCloudKey(from url: URL) async throws -> ArchiveItem {
        let filename = url.lastPathComponent
        logger.debug("importing icloud key: \(filename)")

        let doc = CloudDocument(fileURL: url)
        guard await doc.open(), let data = doc.data else {
            throw Error.cantOpenKey
        }
        return try .init(filename: filename, data: data)
    }
}

// MARK: Sharing

public func shareAsFile(_ key: ArchiveItem) {
    let urls = FileManager.default.urls(
        for: .cachesDirectory, in: .userDomainMask)

    guard let publicDirectory = urls.first else {
        return
    }

    let fileURL = publicDirectory.appendingPathComponent(key.filename)

    FileManager.default.createFile(
        atPath: fileURL.path,
        contents: key.content.data(using: .utf8))

    share([fileURL]) {_, _, _, _ in
        try? FileManager.default.removeItem(at: fileURL)
    }
}
