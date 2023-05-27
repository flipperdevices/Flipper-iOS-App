import Foundation

class CustomExporter: Exporter {
    func exportKey(_ key: ArchiveItem) async throws -> URL {
        let data = Data(key.content.utf8).base64EncodedString()
        guard let url = URL(string: "flipper://\(key.filename)/\(data)") else {
            throw ExportError.encodingError
        }
        return url
    }
}
