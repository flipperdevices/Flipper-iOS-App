import Core
import SwiftUI

struct MainView: View {
    @EnvironmentObject var device: Device
    @EnvironmentObject var archive: ArchiveModel

    @StateObject var tabViewController: TabViewController = .init()

    @AppStorage(.selectedTab) var selectedTab: TabView.Tab = .device

    @State private var showTodayWidgetSettings = false

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
            case .todayWidgetSettings:
                showTodayWidgetSettings = true
            case .updateDeviceLink:
                selectedTab = .device
                tabViewController.popToRootView(for: .device)
            default:
                break
            }
        }
        .fullScreenCover(isPresented: $showTodayWidgetSettings) {
            TodayWidgetSettingsView()
        }
    }
}
