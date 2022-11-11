import UI
import SwiftUI
import NotificationCenter
import Core

var registerDependenciesOnce: Void = {
    Core.registerWidgetDependencies()
}()

class TodayViewController: UIViewController, NCWidgetProviding {
    let compactModeHeight = 110.0
    @ObservedObject var viewModel: WidgetViewModel

    required init?(coder: NSCoder) {
        _ = registerDependenciesOnce
        viewModel = .init()
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Enable expanded mode
        self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        // Add SwiftUI
        let widgetView = WidgetView(viewModel: viewModel)
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
        viewModel.isExpanded = activeDisplayMode == .expanded
        switch activeDisplayMode {
        case .compact:
            preferredContentSize.height = compactModeHeight
        case .expanded:
            let rowsCount = ((UserDefaults.widget?.keys.count ?? 1) / 2 + 1)
            preferredContentSize.height = compactModeHeight * Double(rowsCount)
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
