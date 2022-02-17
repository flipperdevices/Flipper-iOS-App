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
