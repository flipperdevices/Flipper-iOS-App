import UIKit

func share(
    _ items: [Any],
    completion: UIActivityViewController.CompletionWithItemsHandler? = nil
) {
    let activityContoller = UIActivityViewController(
        activityItems: items,
        applicationActivities: nil)
    activityContoller.completionWithItemsHandler = completion

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
        .present(activityContoller, animated: true, completion: nil)
}
