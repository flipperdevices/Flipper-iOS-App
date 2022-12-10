import Core
import SwiftUI
import Combine
import OrderedCollections

struct ArchiveView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var archiveService: ArchiveService

    @State var importedItem: URL?
    @State var selectedItem: ArchiveItem?
    @State var showSearchView = false
    @State var showWidgetSettings = false {
        didSet {
            if appState.showWidgetSettings != showWidgetSettings {
                appState.showWidgetSettings = showWidgetSettings
            }
        }
    }

    var canPullToRefresh: Bool {
        appState.status == .connected ||
        appState.status == .synchronized
    }

    var items: [ArchiveItem] {
        archiveService.items
    }

    var sortedItems: [ArchiveItem] {
        archiveService.items.sorted { $0.date < $1.date }
    }

    var favoriteItems: [ArchiveItem] {
        sortedItems.filter { $0.isFavorite }
    }

    var groups: OrderedDictionary<ArchiveItem.Kind, Int> {
        [
            .subghz: items.filter { $0.kind == .subghz }.count,
            .rfid: items.filter { $0.kind == .rfid }.count,
            .nfc: items.filter { $0.kind == .nfc }.count,
            .infrared: items.filter { $0.kind == .infrared }.count,
            .ibutton: items.filter { $0.kind == .ibutton }.count
        ]
    }

    var body: some View {
        NavigationView {
            VStack {
                if appState.status == .connecting {
                    VStack(spacing: 4) {
                        Spinner()
                        Text("Connecting to Flipper...")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.black30)
                    }
                } else if appState.status == .synchronizing {
                    VStack(spacing: 4) {
                        Spinner()
                        Text(
                            appState.syncProgress == 0
                                ? "Syncing..."
                                : "Syncing \(appState.syncProgress)%"
                        )
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.black30)
                    }
                } else {
                    RefreshableScrollView(
                        isEnabled: canPullToRefresh,
                        action: refresh
                    ) {
                        CategoryCard(
                            groups: groups,
                            deletedCount: archiveService.deleted.count
                        )
                        .padding(14)

                        if !favoriteItems.isEmpty {
                            FavoritesSection(items: favoriteItems) { item in
                                selectedItem = item
                            }
                            .padding(.horizontal, 14)
                            .padding(.bottom, 14)
                        }

                        if !archiveService.items.isEmpty {
                            AllItemsSection(items: sortedItems) { item in
                                selectedItem = item
                            }
                            .padding(.horizontal, 14)
                            .padding(.bottom, 14)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                LeadingToolbarItems {
                    Title("Archive")
                        .padding(.leading, 8)
                }
                TrailingToolbarItems {
                    SearchButton {
                        showSearchView = true
                    }
                }
            }
            .sheet(item: $selectedItem) { item in
                InfoView(item: item)
            }
            .sheet(item: $importedItem) { item in
                ImportView(url: item)
//                    .environmentObject(archiveService)
            }
            .fullScreenCover(isPresented: $showSearchView) {
                ArchiveSearchView()
            }
            .fullScreenCover(isPresented: $showWidgetSettings) {
                WidgetSettingsView()
            }
            .navigationTitle("")
        }
        .navigationViewStyle(.stack)
        .navigationBarColors(foreground: .primary, background: .a1)
        .onChange(of: appState.importQueue) { queue in
            guard !queue.isEmpty else {
                return
            }
            importedItem = appState.importQueue.removeFirst()
        }
    }

    func refresh() {
        appState.synchronize()
    }
}

extension URL: Identifiable {
    public var id: URL {
        self
    }
}
