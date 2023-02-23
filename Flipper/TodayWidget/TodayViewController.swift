import UI
import Combine
import SwiftUI
import NotificationCenter
import Core

class TodayViewController: UIViewController, WidgetProviding {
    private let widget = Dependencies.shared.widget

    private var keysCount: Int = 0
    private var isError: Bool = false
    private var cancellables: [AnyCancellable] = []

    private let compactModeHeight = 110.0

    private var expandedModeHeight: Double {
        let rowsCount = keysCount / 2 + 1
        return compactModeHeight * Double(rowsCount)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Enable expanded mode
        self.extensionContext?.widgetAvailableDisplayMode = .expanded
        // Add SwiftUI
        let widgetView = WidgetView()
            .environmentObject(widget)
        let hostingController = UIHostingController(rootView: widgetView)
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        hostingController.view.addConstraints(to: self.view)

        subscribeToKeysChanged()
    }

    func subscribeToKeysChanged() {
        widget.$keys
            .sink { [weak self] keys in
                guard let self else { return }
                self.keysCount = keys.count
                updatePreferredHeight()
            }
            .store(in: &cancellables)

        widget.$error
            .sink { [weak self] error in
                guard let self else { return }
                isError = error != nil
                updatePreferredHeight()
            }
            .store(in: &cancellables)
    }

    func widgetPerformUpdate(
        completionHandler: (@escaping (UpdateResult) -> Void)
    ) {
        // Perform any setup necessary in order to update the view.

        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData

        completionHandler(.newData)
    }

    func widgetActiveDisplayModeDidChange(
        _ activeDisplayMode: WidgetDisplayMode,
        withMaximumSize maxSize: CGSize
    ) {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            widget.isExpanded = activeDisplayMode == .expanded
        }
        updatePreferredHeight()
    }

    func updatePreferredHeight() {
        guard !isError else {
            preferredContentSize.height = compactModeHeight
            return
        }
        switch widget.isExpanded {
        case true: preferredContentSize.height = expandedModeHeight
        case false: preferredContentSize.height = compactModeHeight
        }
    }
}

private extension UIView {
    func addConstraints(to view: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        backgroundColor = .clear
    }
}
