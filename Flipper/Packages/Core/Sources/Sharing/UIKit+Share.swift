import UIKit

func share(
    _ items: [Any],
    completion: UIActivityViewController.CompletionWithItemsHandler? = nil
) {
    let activityContoller = UIActivityViewController(
        activityItems: items,
        applicationActivities: nil)
    activityContoller.completionWithItemsHandler = completion

    UIApplication.shared
        .windows
        .first?
        .rootViewController?
        .dismiss(animated: true)

    UIApplication.shared
        .windows
        .first?
        .rootViewController?
        .present(activityContoller, animated: true, completion: nil)
}
