import UIKit

extension UIApplication {
    func currentUIWindow() -> UIWindow? {
        let connectedScenes = UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }

        let window = connectedScenes.first?
            .windows
            .first { $0.isKeyWindow }

        return window
    }
}

extension UIViewController {
    func firstChild(withChildrenCount childrenCount: Int) -> UIViewController? {
        guard children.count != childrenCount else {
            return self
        }
        for child in children {
            if let child = child.firstChild(withChildrenCount: childrenCount) {
                return child
            }
        }
        return nil
    }
}

extension UISplitViewController {
    func popToRootViewController(animated: Bool) {
        for child in children {
            if let child = child as? UINavigationController {
                child.popToRootViewController(animated: animated)
            }
        }
    }
}
