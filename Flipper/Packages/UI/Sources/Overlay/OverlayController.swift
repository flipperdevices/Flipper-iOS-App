import SwiftUI

class OverlayController: ObservableObject {
    private var overlay: UIWindow?
    private var views: [UIView]

    init() {
        self.overlay = OverlayWindow()
        self.views = []
    }

    func present<Content: View>(
        @ViewBuilder content: @escaping () -> Content
    ) {
        guard let overlay else { return }

        let viewController = UIHostingController(
            rootView: content()
        )
        viewController.view.backgroundColor = .clear

        if let rootViewController = overlay.rootViewController {
            viewController.view.frame = rootViewController.view.frame
            views.append(viewController.view)
        } else {
            overlay.rootViewController = viewController
            overlay.isUserInteractionEnabled = true
            overlay.isHidden = false
        }
    }

    func dismiss() {
        guard let overlay else { return }

        Task { @MainActor in
            try? await Task.sleep(seconds: 0.1)

            if views.isEmpty {
                overlay.isHidden = true
                overlay.isUserInteractionEnabled = false
                overlay.rootViewController = nil
            } else {
                let first = views.removeFirst()
                guard
                    let rootViewController = overlay.rootViewController
                else {
                    return
                }
                rootViewController.view.subviews.forEach { view in
                    view.removeFromSuperview()
                }
                rootViewController.view.addSubview(first)
            }
        }
    }
}
