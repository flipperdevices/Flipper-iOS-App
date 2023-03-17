#if canImport(UIKit)
import UIKit

class CloudDocument: UIDocument {
    var data: Data?

    override func load(
        fromContents contents: Any,
        ofType typeName: String?
    ) throws {
        self.data = contents as? Data
    }
}
#endif
