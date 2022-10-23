import Core
import Inject
import Peripheral
import Combine
import SwiftUI

@MainActor
class MainViewModel: ObservableObject {
    @AppStorage(.selectedTabKey) var selectedTab: TabView.Tab = .device {
        didSet {
            if oldValue == selectedTab {
                popToRootView()
            }
        }
    }

    @Published var importedName = ""
    @Published var importedOpacity = 0.0

    @Inject var central: BluetoothCentral

    let appState: AppState = .shared
    var disposeBag: DisposeBag = .init()

    init() {
        central.startScanForPeripherals()
        central.stopScanForPeripherals()

        appState.imported
            .receive(on: DispatchQueue.main)
            .sink { [weak self] item in
                self?.onItemAdded(item: item)
            }
            .store(in: &disposeBag)
    }

    // 🪄🪄🪄🪄🪄🪄🪄
    func popToRootView() {
        let rootViewController = UIApplication
            .shared
            .currentUIWindow()?
            .rootViewController?
            .firstChild(withChildrenCount: TabView.Tab.allCases.count)

        guard
            let rootViewController = rootViewController,
            let index = TabView.Tab.allCases.firstIndex(of: selectedTab)
        else {
            return
        }

        switch rootViewController.children[index] {
        case let controller as UINavigationController:
            _ = controller.popToRootViewController(animated: true)
        case let controller as UISplitViewController:
            controller.popToRootViewController(animated: true)
        default:
            break
        }
    }

    func onItemAdded(item: ArchiveItem) {
        importedName = item.name.value
        Task { @MainActor in
            try await Task.sleep(milliseconds: 200)
            withAnimation { importedOpacity = 1.0 }
            try await Task.sleep(seconds: 3)
            withAnimation { importedOpacity = 0 }
        }
    }
}
