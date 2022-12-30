import Core
import SwiftUI

struct MainView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var centralService: CentralService
    @StateObject var tabViewController: TabViewController = .init()

    @AppStorage(.selectedTabKey) var selectedTab: TabView.Tab = .device {
        didSet {
            if oldValue == selectedTab {
                tabViewController.popToRootView(for: selectedTab)
            }
        }
    }

    @State var importedName = ""
    @State var importedOpacity = 0.0

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                DeviceView()
                    .opacity(selectedTab == .device ? 1 : 0)
                ArchiveView()
                    .opacity(selectedTab == .archive ? 1 : 0)
                HubView()
                    .opacity(selectedTab == .hub ? 1 : 0)

                ImportedBanner(itemName: importedName)
                    .opacity(importedOpacity)
            }

            if !tabViewController.isHidden {
                TabView(selected: $selectedTab)
                    .transition(.move(edge: .bottom))
            }
        }
        .edgesIgnoringSafeArea(.bottom)
        .environmentObject(tabViewController)
        .onReceive(appState.imported) { item in
            onItemAdded(item: item)
        }
        .onOpenURL { url in
            if url == .widgetSettings {
                appState.widget.showSettings = true
            }
        }
        .fullScreenCover(isPresented: $appState.widget.showSettings) {
            WidgetSettingsView()
        }
        .onAppear {
            centralService.kickBluetoothCentral()
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
