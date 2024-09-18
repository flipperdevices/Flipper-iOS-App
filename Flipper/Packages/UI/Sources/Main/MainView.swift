import Core
import SwiftUI
import WidgetKit

struct MainView: View {
    @EnvironmentObject var device: Device
    @EnvironmentObject var archive: ArchiveModel
    @EnvironmentObject var emulate: Emulate

    @StateObject var tabViewController: TabViewController = .init()

    @AppStorage(.selectedTab) var selectedTab: TabView.Tab = .device

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                DeviceView()
                    .opacity(selectedTab == .device ? 1 : 0)
                ArchiveView()
                    .opacity(selectedTab == .archive ? 1 : 0)
                AppsView()
                    .opacity(selectedTab == .apps ? 1 : 0)
                HubView()
                    .opacity(selectedTab == .hub ? 1 : 0)
            }

            if !tabViewController.isHidden {
                TabView(selected: $selectedTab) {
                    tabViewController.popToRootView(for: selectedTab)
                }
                .transition(.move(edge: .bottom))
            }
        }
        .ignoresSafeArea(.keyboard)
        .environmentObject(tabViewController)
        .onOpenURL { url in
            switch url {
            case .updateDeviceLink:
                selectedTab = .device
                tabViewController.popToRootView(for: .device)
            default:
                break
            }
        }
        .onReceive(device.$status) { status in
            if status == .disconnected {
                UserDefaults.group.set("", forKey: "emulating")
                UserDefaults.group.synchronize()
                emulate.stopEmulate()
                WidgetCenter.shared.reloadTimelines(ofKind: "LiveWidget")
            }
        }
    }
}
