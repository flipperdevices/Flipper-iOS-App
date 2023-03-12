import UIKit
import Combine

class TabViewController: ObservableObject {
    @Published var isHidden = false

    func show() {
        isHidden = false
    }

    func hide() {
        isHidden = true
    }

    // 🪄🪄🪄🪄🪄🪄🪄
    func popToRootView(for tab: TabView.Tab) {
        let rootViewController = UIApplication
            .shared
            .currentUIWindow()?
            .rootViewController?
            .firstChild(withChildrenCount: TabView.Tab.allCases.count)

        guard
            let rootViewController = rootViewController,
            let index = TabView.Tab.allCases.firstIndex(of: tab)
        else {
            return
        }

        switch rootViewController.children[index] {
        case let controller as UINavigationController:
            controller.popToRootViewController(animated: true)
        case let controller as UISplitViewController:
            controller.popToRootViewController(animated: true)
        default:
            break
        }
    }
}
