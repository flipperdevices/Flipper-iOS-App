import UIKit

func share(
    _ items: [Any],
    completion: UIActivityViewController.CompletionWithItemsHandler? = nil
) {
    let activityController = UIActivityViewController(
        activityItems: items,
        applicationActivities: nil)
    activityController.completionWithItemsHandler = completion

    var topController = (UIApplication
        .shared
        .connectedScenes
        .first as? UIWindowScene)?
        .windows
        .first?
        .rootViewController

    while let presentedViewController = topController?.presentedViewController {
        topController = presentedViewController
    }

    topController?.present(activityController, animated: true, completion: nil)
}

func share(_ url: URL?, completion: @escaping () -> Void = {}) {
    if let url = url {
        share([url]) { _, _, _, _ in
            completion()
        }
    }
}

func shareFile(name: String, content: String) {
    guard let url = try? FileManager.default.createTempFile(
        name: name,
        content: content
    ) else {
        return
    }

    share([url]) { _, _, _, _ in
        try? FileManager.default.removeItem(at: url)
    }
}

func shareImage(name: String, ext: String = "png", data: Data) {
    guard
        let url = try? FileManager.default.createTempFile(
            name: "\(name).\(ext)",
            data: data
        )
    else {
        return
    }
    UI.share(url) {
        try? FileManager.default.removeItem(at: url)
    }
}
