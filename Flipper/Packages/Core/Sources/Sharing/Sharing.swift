import Logging
import Foundation

public class Sharing {
    let logger = Logger(label: "sharing")

    public static let shared: Sharing = .init()

    let appState: AppState = .shared

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
            case "flipper": try await importCustom(keyURL)
            default: break
            }
            logger.info("key imported")
        } catch {
            logger.critical("\(error)")
        }
    }
}

// MARK: Helper for importing File / Custom Scheme

extension Sharing {
    func importKey(name: String, data: Data) async throws {
        let content = String(decoding: data, as: UTF8.self)
        try await self.importKey(name: name, content: content)
    }

    private func importKey(name: String, content: String) async throws {
        guard let item = ArchiveItem(fileName: name, content: content) else {
            logger.error("importing error, invalid data")
            return
        }
        try await appState.importKey(item)
    }
}
