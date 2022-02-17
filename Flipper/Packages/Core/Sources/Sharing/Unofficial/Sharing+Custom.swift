import Foundation

class CustomImporter: Importer {
    enum Error: String, Swift.Error {
        case invalidURL = "invalid url"
        case invalidData = "invalid data"
    }

    func importKey(from url: URL) async throws -> ArchiveItem {
        guard
            let filename = url.host,
            let content = url.pathComponents.last
        else {
            throw Error.invalidURL
        }
        guard let data = Data(base64Encoded: content) else {
            throw Error.invalidData
        }
        return try .init(filename: filename, data: data)
    }
}

private func shareCustom(_ key: ArchiveItem) {
    let base64String = Data(key.content.utf8).base64EncodedString()
    let urlString = "flipper://\(key.filename)/\(base64String)"
    share([urlString])
}
