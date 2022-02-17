import Foundation

extension Sharing {
    func importCustom(_ url: URL) async throws {
        guard let name = url.host, let content = url.pathComponents.last else {
            throw Error.invalidURL
        }
        guard let data = Data(base64Encoded: content) else {
            throw Error.invalidData
        }
        try await importKey(name: name, data: data)
    }
}

func shareCustom(_ key: ArchiveItem) {
    let base64String = Data(key.content.utf8).base64EncodedString()
    let urlString = "flipper://\(key.fileName)/\(base64String)"
    share([urlString])
}
