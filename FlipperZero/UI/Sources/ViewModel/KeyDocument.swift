import UIKit

class KeyDocument: UIDocument {
    var data: Data?

    override func load(
        fromContents contents: Any,
        ofType typeName: String?
    ) throws {
        self.data = contents as? Data
    }
}