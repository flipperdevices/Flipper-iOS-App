import Foundation

extension FileManager {
    public func createTempFile(name: String, content: String) throws -> URL {
        try createTempFile(name: name, data: .init(content.utf8))
    }

    public func createTempFile(name: String, data: Data) throws -> URL {
        let fileURL = FileManager.default
            .temporaryDirectory
            .appendingPathComponent(name)

        if FileManager.default.fileExists(atPath: fileURL.path) {
            try FileManager.default.removeItem(atPath: fileURL.path)
        }

        try data.write(to: fileURL)

        return fileURL
    }
}
