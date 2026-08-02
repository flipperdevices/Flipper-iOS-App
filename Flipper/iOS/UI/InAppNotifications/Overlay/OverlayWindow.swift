import SwiftUI

class OverlayWindow: UIWindow {
    // NOTE: Hit-testing is driven by the interaction mode declared
    // by the visible overlay instead of inspecting the private
    // UIHostingController view hierarchy which changes between
    // iOS releases (broke on iOS 18 and again on iOS 26)
    var interaction: OverlayInteraction?

    init?(scene: UIScene? = UIApplication.shared.connectedScenes.first) {
        guard let windowScene = scene as? UIWindowScene else { return nil }
        super.init(windowScene: windowScene)
        isHidden = true
        isUserInteractionEnabled = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        switch interaction {
        case .fullscreen:
            return true
        case .regions(let regions):
            return regions.contains { $0.contains(point) }
        case .none:
            return false
        }
    }
}
