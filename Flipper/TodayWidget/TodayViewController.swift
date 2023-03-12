import UI
import Combine
import SwiftUI
import NotificationCenter
import Core

class TodayViewController: UIViewController, WidgetProviding {
    private let widget = Dependencies.shared.widget

    private var isError: Bool = false
    private var cancellables: [AnyCancellable] = []

    private let compactModeHeight = 110.0
    private var expandedModeHeight = 110.0

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
            .onHeightChanged { [weak self] in
                guard let self else { return }
                self.expandedModeHeight = $0
                self.updatePreferredHeight()
            }
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
                self.view.setNeedsLayout()
            }
            .store(in: &cancellables)

        widget.$error
            .sink { [weak self] error in
                guard let self else { return }
                self.isError = error != nil
                self.updatePreferredHeight()
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
        widget.isExpanded = activeDisplayMode == .expanded
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
        bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        backgroundColor = .clear
    }
}

extension View {
    func onHeightChanged(_ action: @escaping (Double) -> Void) -> some View {
        self
            .background(GeometryReader {
                Color.clear.preference(
                    key: HeightPreferenceKey.self,
                    value: $0.frame(in: .global).height
                )
            })
            .onPreferenceChange(HeightPreferenceKey.self, perform: action)
    }
}

private struct HeightPreferenceKey: PreferenceKey {
    typealias Value = Double

    static var defaultValue = Double.zero

    static func reduce(value: inout Value, nextValue: () -> Value) {
        let height = nextValue()
        guard
            height != 0.0,
            height != value
        else {
            return
        }
        value = height
    }
}
