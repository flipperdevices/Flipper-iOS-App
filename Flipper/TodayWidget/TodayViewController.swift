import SwiftUI
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Add SwiftUI
        let hostingController = UIHostingController(rootView: ContentView())
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        hostingController.view.addConstraints(to: self.view)
    }

    func widgetPerformUpdate(
        completionHandler: (@escaping (NCUpdateResult) -> Void)
    ) {
        // Perform any setup necessary in order to update the view.

        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData

        completionHandler(.newData)
    }
}

private extension UIView {
    func addConstraints(to view: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        backgroundColor = .clear
    }
}
