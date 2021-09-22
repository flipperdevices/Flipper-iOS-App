import SwiftUI

func share(_ items: [Any]) {
    let activityContoller = UIActivityViewController(
        activityItems: items,
        applicationActivities: nil)
    UIApplication.shared
        .windows
        .first?
        .rootViewController?
        .present(activityContoller, animated: true, completion: nil)
}
