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
                UserDefaults.group.set(-1, forKey: "battery_level")
                UserDefaults.group.set(false, forKey: "battery_charging")
                UserDefaults.group.synchronize()

                emulate.stopEmulate()
                WidgetCenter.shared.reloadTimelines(ofKind: "LiveWidget")
                WidgetCenter.shared.reloadTimelines(ofKind: "BatteryWidget")
            }
        }
        .onReceive(device.$flipper) { flipper in
            let battery = flipper?.battery?.level ?? -1
            let isCharging = flipper?.battery?.state == .charging

            UserDefaults.group.set(battery, forKey: "battery_level")
            UserDefaults.group.set(isCharging, forKey: "battery_charging")
            UserDefaults.group.synchronize()
            WidgetCenter.shared.reloadTimelines(ofKind: "BatteryWidget")
        }
    }
}
