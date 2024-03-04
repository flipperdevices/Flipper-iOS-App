import SwiftUI

class OverlayController: ObservableObject {
    var rootVC: UIViewController?

    @MainActor func present<Content: View>(
        @ViewBuilder content: @escaping () -> Content
    ) {
        let viewController = UIHostingController(rootView: content())
        viewController.view.backgroundColor = .clear
        viewController.modalTransitionStyle = .crossDissolve
        viewController.modalPresentationStyle = .overCurrentContext

        self.rootVC = UIApplication
            .shared
            .connectedScenes
            .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
            .first(where: { $0.isKeyWindow })?.rootViewController

        rootVC?.present(viewController, animated: true)
    }

    @MainActor func dismiss() {
        rootVC?.dismiss(animated: false)
    }
}
