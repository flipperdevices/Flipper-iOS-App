import Core
import SwiftUI
import Combine
import OrderedCollections

struct ArchiveView: View {
    @EnvironmentObject var device: Device
    @EnvironmentObject var archive: ArchiveModel
    @EnvironmentObject var synchronization: Synchronization

    @State private var importedItem: URL?
    @State private var selectedItem: ArchiveItem?
    @State private var showSearchView = false

    var canPullToRefresh: Bool {
        device.status == .connected ||
        device.status == .synchronized
    }

    var items: [ArchiveItem] {
        archive.items
    }

    var sortedItems: [ArchiveItem] {
        archive.items.sorted { $0.date < $1.date }
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
                if device.status == .connecting {
                    VStack(spacing: 4) {
                        Spinner()
                        Text("Connecting to Flipper...")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.black30)
                    }
                } else if device.status == .synchronizing {
                    VStack(spacing: 4) {
                        Spinner()
                        Text(
                            synchronization.progress == 0
                                ? "Syncing..."
                                : "Syncing \(synchronization.progress)%"
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
                            deletedCount: archive.deleted.count
                        )
                        .padding(14)

                        if !favoriteItems.isEmpty {
                            FavoritesSection(items: favoriteItems) { item in
                                selectedItem = item
                            }
                            .padding(.horizontal, 14)
                            .padding(.bottom, 14)
                        }

                        if !archive.items.isEmpty {
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
            }
            .fullScreenCover(isPresented: $showSearchView) {
                ArchiveSearchView()
            }
            .navigationTitle("")
        }
        .navigationViewStyle(.stack)
        .navigationBarColors(foreground: .primary, background: .a1)
        .onOpenURL { url in
            if url.isKeyURL, importedItem == nil {
                importedItem = url
            }
        }
    }

    func refresh() {
        synchronization.start()
    }
}

private extension URL {
    var isKeyURL: Bool {
        path == "/s" || path == "/sf"
    }
}

extension URL: Identifiable {
    public var id: URL {
        self
    }
}
