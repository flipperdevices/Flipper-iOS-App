import UIKit

public func share(
    _ items: [Any],
    completion: UIActivityViewController.CompletionWithItemsHandler? = nil
) {
    let activityController = UIActivityViewController(
        activityItems: items,
        applicationActivities: nil)
    activityController.completionWithItemsHandler = completion

    (UIApplication
        .shared
        .connectedScenes
        .first as? UIWindowScene)?
        .windows
        .first?
        .rootViewController?
        .dismiss(animated: true)

    (UIApplication
        .shared
        .connectedScenes
        .first as? UIWindowScene)?
        .windows
        .first?
        .rootViewController?
        .present(activityController, animated: true, completion: nil)
}
