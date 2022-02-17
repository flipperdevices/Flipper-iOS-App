import UIKit
import Foundation

extension Sharing {
    class KeyDocument: UIDocument {
        var data: Data?

        override func load(
            fromContents contents: Any,
            ofType typeName: String?
        ) throws {
            self.data = contents as? Data
        }
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
}

func shareFile(_ key: ArchiveItem) {
    let urls = FileManager.default.urls(
        for: .cachesDirectory, in: .userDomainMask)

    guard let publicDirectory = urls.first else {
        return
    }

    let fileURL = publicDirectory.appendingPathComponent(key.fileName)

    FileManager.default.createFile(
        atPath: fileURL.path,
        contents: key.content.data(using: .utf8))

    share([fileURL]) {_, _, _, _ in
        try? FileManager.default.removeItem(at: fileURL)
    }
}
