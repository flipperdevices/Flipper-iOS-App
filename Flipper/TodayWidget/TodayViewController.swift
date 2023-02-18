import UI
import SwiftUI
import NotificationCenter
import Core

class TodayViewController: UIViewController, NCWidgetProviding {
    let compactModeHeight = 110.0

    // next step
    var isError: Bool = false
    var isExpanded: Bool = false
    var expandedModeHeight: Double {
        let keysCount = 0
        let rowsCount = keysCount / 2 + 1
        return compactModeHeight * Double(rowsCount)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Enable expanded mode
        self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        // Add SwiftUI
        let widgetView = WidgetView()
        let hostingController = UIHostingController(rootView: widgetView)
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

    func widgetActiveDisplayModeDidChange(
        _ activeDisplayMode: NCWidgetDisplayMode,
        withMaximumSize maxSize: CGSize
    ) {
        isExpanded = activeDisplayMode == .expanded

        guard !isError else {
            preferredContentSize.height = compactModeHeight
            return
        }

        switch activeDisplayMode {
        case .compact: preferredContentSize.height = compactModeHeight
        case .expanded: preferredContentSize.height = expandedModeHeight
        @unknown default: break
        }
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
