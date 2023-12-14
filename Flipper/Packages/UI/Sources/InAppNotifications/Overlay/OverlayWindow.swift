import SwiftUI

class OverlayWindow: UIWindow {
    init?(scene: UIScene? = UIApplication.shared.connectedScenes.first) {
        guard let windowScene = scene as? UIWindowScene else { return nil }
        super.init(windowScene: windowScene)
        isHidden = true
        isUserInteractionEnabled = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let view = super.hitTest(point, with: event) else { return nil }
        return rootViewController?.view == view ? nil : view
    }
}
