import SwiftUI

@available(iOS 15.0, *)
extension View {
    func cardSheet<SheetView: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> SheetView
    ) -> some View {
        self.background {
            SheetViewProxy(sheetView: content(), isPresented: isPresented)
        }
    }
}

@available(iOS 15.0, *)
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

@available(iOS 15.0, *)
class HostingController<Content: View>: UIHostingController<Content> {
    override func viewDidLoad() {
        super.viewDidLoad()
        // swiftlint:disable opening_brace
        if let presentationContoller = presentationController
            as? UISheetPresentationController
        {
            presentationContoller.detents = [.medium()]
            presentationContoller.prefersGrabberVisible = true
        }
    }
}
