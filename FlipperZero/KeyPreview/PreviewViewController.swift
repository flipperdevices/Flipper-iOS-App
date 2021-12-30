import UIKit
import QuickLook

class PreviewViewController: UIViewController, QLPreviewingController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func preparePreviewOfFile(
        at url: URL,
        completionHandler handler: @escaping (Error?) -> Void
    ) {
        handler(nil)
    }
}
