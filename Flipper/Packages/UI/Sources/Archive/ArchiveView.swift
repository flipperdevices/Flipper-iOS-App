import Core
import SwiftUI
import Combine
import OrderedCollections
import UniformTypeIdentifiers

struct ArchiveView: View {
    @EnvironmentObject var device: Device
    @EnvironmentObject var archive: ArchiveModel
    @EnvironmentObject var synchronization: Synchronization

    @Environment(\.notifications) private var notifications

    @AppStorage(.selectedTab) var selectedTab: TabView.Tab = .device

    @State private var path = NavigationPath()

    @State private var importedName = ""

    @State private var predicate = ""
    @State private var showSearchView = false

    enum Destination: Hashable {
        case info(ArchiveItem)
        case infoDeleted(ArchiveItem)
        case importing(URL)
        case category(ArchiveItem.Kind)
        case categoryDeleted
    }

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
        NavigationStack(path: $path) {
            VStack {
                if device.status == .synchronizing {
                    SyncProgress(synchronization.progress)
                } else if !predicate.isEmpty {
                    ArchiveSearchView(predicate: $predicate)
                } else {
                    ScrollView {
                        CategoryCard(
                            groups: groups,
                            deletedCount: archive.deleted.count
                        )
                        .padding(14)

                        if !favoriteItems.isEmpty {
                            FavoritesSection(items: favoriteItems)
                                .padding(.horizontal, 14)
                                .padding(.bottom, 14)
                        }

                        if !archive.items.isEmpty {
                            AllItemsSection(items: sortedItems)
                                .padding(.horizontal, 14)
                                .padding(.bottom, 14)
                        }
                    }
                    .refreshable(isEnabled: canPullToRefresh) {
                        refresh()
                    }
                }
            }
            // NOTE: Fixes Connecting/Syncing views size
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.background)
            .navigationBarBackground(Color.a1)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("")
            .toolbar {
                if !showSearchView {
                    LeadingToolbarItems {
                        Title("Archive")
                            .padding(.leading, 8)
                    }

                    TrailingToolbarItems {
                        SearchButton {
                            showSearchView = true
                        }
                    }
                } else {
                    PrincipalToolbarItems {
                        HStack(spacing: 14) {
                            SearchField(
                                placeholder: "Search by name and note",
                                predicate: $predicate
                            )

                            CancelSearchButton {
                                predicate = ""
                                showSearchView = false
                            }
                        }
                    }
                }
            }
            .onReceive(archive.imported) { item in
                onItemAdded(item: item)
            }
            .notification(isPresented: notifications.archive.showImported) {
                ImportedBanner(itemName: importedName)
            }
            .navigationDestination(for: Destination.self) { destination in
                switch destination {
                case .info(let item): InfoView(item: item)
                case .infoDeleted(let item): DeletedInfoView(item: item)
                case .importing(let url): ImportView(url: url)
                case .category(let kind): CategoryView(kind: kind)
                case .categoryDeleted: CategoryDeletedView()
                }
            }
        }
        .tint(.primary)
        .environment(\.path, $path)
        .onOpenURL { url in
            if url.isKeyFile || url.isKeyURL {
                path.append(Destination.importing(url))
                selectedTab = .archive
            }
        }
        .onDrop(of: [.item], isTargeted: nil) { providers in
            guard let provider = providers.first else { return false }
            provider.loadItem(
                forTypeIdentifier: UTType.item.identifier,
                options: nil
            ) { (data, _) in
                guard let url = data as? URL else { return }
                path.append(Destination.importing(url))
            }
            return true
        }
    }

    func refresh() {
        synchronization.start()
    }

    func onItemAdded(item: ArchiveItem) {
        Task { @MainActor in
            try? await Task.sleep(seconds: 1)
            importedName = item.name.value
            notifications.archive.showImported = true
        }
    }
}

private extension URL {
    var isKeyFile: Bool {
        (try? ArchiveItem.Kind(.init(string: path))) != nil
    }

    var isKeyURL: Bool {
        path == "/s" || path == "/sf"
    }
}
