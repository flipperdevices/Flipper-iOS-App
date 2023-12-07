import Core
import SwiftUI

struct MainView: View {
    @EnvironmentObject var device: Device
    @EnvironmentObject var archive: ArchiveModel

    @StateObject var tabViewController: TabViewController = .init()

    @AppStorage(.selectedTabKey) var selectedTab: TabView.Tab = .device

    @State private var importedName = ""
    @State private var showImported = false

    @State private var showTodayWidgetSettings = false

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                DeviceView()
                    .opacity(selectedTab == .device ? 1 : 0)
                ArchiveView()
                    .opacity(selectedTab == .archive ? 1 : 0)
                HubView()
                    .opacity(selectedTab == .hub ? 1 : 0)
            }
            .notification(isPresented: $showImported) {
                ImportedBanner(itemName: importedName)
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
        .onReceive(archive.imported) { item in
            onItemAdded(item: item)
        }
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

    func onItemAdded(item: ArchiveItem) {
        Task { @MainActor in
            try? await Task.sleep(seconds: 1)
            importedName = item.name.value
            showImported = true
        }
    }
}
