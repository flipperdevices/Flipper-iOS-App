import UIKit
import QuickLook

class PreviewViewController: UIViewController, QLPreviewingController {
    nonisolated func preparePreviewOfFile(
        at url: URL,
        completionHandler handler: @escaping (Error?) -> Void
    ) {
        handler(nil)
    }
}
