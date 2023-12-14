import SwiftUI

class OverlayController: ObservableObject {
    private var overlay: UIWindow?
    private var views: [UIView]

    init() {
        self.overlay = OverlayWindow()
        self.views = []
    }

    func present<Content: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) {
        guard let overlay else { return }

        let viewController = UIHostingController(
            rootView: content()
                .environmentObject(self)
        )
        viewController.view.backgroundColor = .clear

        views.append(viewController.view)

        if let rootViewController = overlay.rootViewController {
            viewController.view.frame = rootViewController.view.frame
        } else {
            overlay.rootViewController = viewController
            overlay.isUserInteractionEnabled = true
            overlay.isHidden = false
        }
    }

    func dismiss() {
        guard let overlay else { return }

        guard !views.isEmpty else {
            return
        }

        views.removeFirst()

        if let first = views.first {
            guard
                let rootViewController = overlay.rootViewController
            else {
                return
            }
            rootViewController.view.subviews.forEach { view in
                view.removeFromSuperview()
            }
            rootViewController.view.addSubview(first)
        } else {
            overlay.isHidden = true
            overlay.isUserInteractionEnabled = false
            overlay.rootViewController = nil
        }
    }
}
