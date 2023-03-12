import Foundation

extension FileManager {
    public func createTempFile(name: String, content: String) throws -> URL {
        let fileURL = FileManager.default
            .temporaryDirectory
            .appendingPathComponent(name)

        if FileManager.default.fileExists(atPath: fileURL.path) {
            try FileManager.default.removeItem(atPath: fileURL.path)
        }

        try content.write(to: fileURL, atomically: true, encoding: .utf8)

        return fileURL
    }
}
