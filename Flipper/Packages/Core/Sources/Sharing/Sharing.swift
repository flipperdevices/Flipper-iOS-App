import Logging
import Foundation

public class Sharing {
    private let logger = Logger(label: "import")

    public static let shared: Sharing = .init()

    let archive: Archive = .shared

    init() {}

    enum Error: String, Swift.Error {
        case invalidURL = "invalid url"
        case invalidData = "invalid data"
        case cantOpenDoc = "error opening doc"
    }

    public func importKey(_ keyURL: URL) async {
        do {
            switch keyURL.scheme {
            case "file": try await importFile(keyURL)
            case "flipper": try await importURL(keyURL)
            default: break
            }
            logger.info("key imported")
        } catch {
            logger.critical("\(error)")
        }
    }

    func importURL(_ url: URL) async throws {
        guard let name = url.host, let content = url.pathComponents.last else {
            throw Error.invalidURL
        }
        guard let data = Data(base64Encoded: content) else {
            throw Error.invalidData
        }
        try await importKey(name: name, data: data)
    }

    func importFile(_ url: URL) async throws {
        let name = url.lastPathComponent

        switch try? Data(contentsOf: url) {
        // internal file
        case .some(let data):
            try FileManager.default.removeItem(at: url)
            logger.debug("importing internal key: \(name)")
            try await importKey(name: name, data: data)
        // icloud file
        case .none:
            let doc = await KeyDocument(fileURL: url)
            guard await doc.open(), let data = await doc.data else {
                throw Error.cantOpenDoc
            }
            logger.debug("importing icloud key: \(name)")
            try await importKey(name: name, data: data)
        }
    }

    func importKey(name: String, data: Data) async throws {
        let content = String(decoding: data, as: UTF8.self)

        guard let item = ArchiveItem(
            fileName: name,
            content: content
        ) else {
            logger.error("importing error, invalid data")
            return
        }

        try await archive.importKey(item)
        await archive.syncWithDevice()
    }
}
