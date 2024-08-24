import SwiftUI

struct WidgetView: View {
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Spacer()
            Text("This Widget is deprecated")
            Text("Use standard Widget from Home Screen")
            Spacer()
        }
    }
}

@objc(TodayViewController)
class TodayViewController: UIViewController, WidgetProviding {
    override func loadView() {
        // Enable expanded mode
        self.extensionContext?.widgetAvailableDisplayMode = .compact
        // Add SwiftUI
        let widgetView = WidgetView()
        let hostingController = UIHostingController(rootView: widgetView)
        addChild(hostingController)

        view = UIView()
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        hostingController.view.addConstraints(to: self.view)
    }

    nonisolated func widgetPerformUpdate(
        completionHandler: (@escaping (UpdateResult) -> Void)
    ) {
        // Perform any setup necessary in order to update the view.

        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData

        completionHandler(.newData)
    }

    nonisolated func widgetActiveDisplayModeDidChange(
        _ activeDisplayMode: WidgetDisplayMode,
        withMaximumSize maxSize: CGSize
    ) {
    }
}

private extension UIView {
    func addConstraints(to view: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        backgroundColor = .clear
    }
}
