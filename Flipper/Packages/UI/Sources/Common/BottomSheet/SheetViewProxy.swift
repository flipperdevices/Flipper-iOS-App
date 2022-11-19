import SwiftUI

extension View {
    func sheetViewProxy<SheetView: View>(
        isPresented: Binding<Bool>,
        detents: [UISheetPresentationController.Detent] = [.medium()],
        @ViewBuilder content: @escaping () -> SheetView
    ) -> some View {
        self.background {
            SheetViewProxy(
                sheetView: content(),
                isPresented: isPresented,
                detents: detents
            )
        }
    }
}

struct SheetViewProxy<SheetView: View>: UIViewControllerRepresentable {
    var sheetView: SheetView
    @Binding var isPresented: Bool
    let detents: [UISheetPresentationController.Detent]

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
            sheetViewController.detents = detents
            uiViewController.present(sheetViewController, animated: true) {
                DispatchQueue.main.async {
                    self.isPresented = false
                }
            }
        }
    }
}

class HostingController<Content: View>: UIHostingController<Content> {
    var detents: [UISheetPresentationController.Detent] = []
    var prefersGrabberVisible = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
        // swiftlint:disable opening_brace
        if let presentationContoller = presentationController
            as? UISheetPresentationController
        {
            presentationContoller.detents = detents
            presentationContoller.prefersGrabberVisible = prefersGrabberVisible
        }
    }
}
