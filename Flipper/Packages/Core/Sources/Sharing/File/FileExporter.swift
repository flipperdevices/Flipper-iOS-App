import Foundation

class FileExporter: Exporter {
    func exportKey(_ item: ArchiveItem) async throws -> URL {
        try FileManager.default.createTempFile(
            name: item.filename,
            content: item.content)
    }
}

