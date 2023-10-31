import SwiftUI

extension View {
    func sheetViewProxy<SheetView: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> SheetView
    ) -> some View {
        self.background(
            SheetViewProxy(
                sheetView: content(),
                isPresented: isPresented
            )
        )
    }
}

struct SheetViewProxy<SheetView: View>: UIViewControllerRepresentable {
    var sheetView: SheetView
    @Binding var isPresented: Bool

    let controller = UIViewController()

    func makeUIViewController(context: Context) -> some UIViewController {
        controller.view.backgroundColor = .clear
        return controller
    }

    func updateUIViewController(
        _ uiViewController: UIViewControllerType,
        context: Context
    ) {
        if isPresented {
            let sheetViewController = HostingController(rootView: sheetView)
            uiViewController.present(sheetViewController, animated: true) {
                DispatchQueue.main.async {
                    self.isPresented = false
                }
            }
        }
    }
}

class HostingController<Content: View>: UIHostingController<Content> {
    var prefersGrabberVisible = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
        if #available (iOS 15, *) {
            // swiftlint:disable opening_brace
            if let presentationController = presentationController
                as? UISheetPresentationController
            {
                presentationController.detents = [.medium()]
                presentationController.prefersGrabberVisible = prefersGrabberVisible
            }
        }
        // swiftlint:enable opening_brace
    }
}
