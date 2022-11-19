import Core
import Inject
import Combine
import Logging
import SwiftUI
import OrderedCollections

@MainActor
class ArchiveViewModel: ObservableObject {
    private let logger = Logger(label: "archive-vm")

    @Environment(\.dismiss) private var dismiss
    @Inject private var appState: AppState
    @Inject private var archive: Archive
    private var disposeBag: DisposeBag = .init()

    let pullToRefreshThreshold: Double = 1000

    @Published var items: [ArchiveItem] = []
    @Published var deleted: [ArchiveItem] = []
    @Published var status: DeviceStatus = .noDevice
    @Published var syncProgress: Int = 0

    var canPullToRefresh: Bool {
        status == .connected ||
        status == .synchronized
    }

    var sortedItems: [ArchiveItem] {
        items.sorted { $0.date < $1.date }
    }

    var favoriteItems: [ArchiveItem] {
        sortedItems.filter { $0.isFavorite }
    }

    var selectedItem: ArchiveItem = .none
    @Published var showInfoView = false
    @Published var showSearchView = false
    @Published var hasImportedItem = false
    @Published var showWidgetSettings = false {
        didSet {
            if appState.showWidgetSettings != showWidgetSettings {
                appState.showWidgetSettings = showWidgetSettings
            }
        }
    }

    var importedItem: URL {
        appState.importQueue.removeFirst()
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

    init() {
        archive.items
            .receive(on: DispatchQueue.main)
            .assign(to: \.items, on: self)
            .store(in: &disposeBag)

        archive.deletedItems
            .receive(on: DispatchQueue.main)
            .assign(to: \.deleted, on: self)
            .store(in: &disposeBag)

        appState.$importQueue
            .receive(on: DispatchQueue.main)
            .map { !$0.isEmpty }
            .filter { $0 == true }
            .assign(to: \.hasImportedItem, on: self)
            .store(in: &disposeBag)

        appState.$status
            .receive(on: DispatchQueue.main)
            .assign(to: \.status, on: self)
            .store(in: &disposeBag)

        appState.$syncProgress
            .receive(on: DispatchQueue.main)
            .assign(to: \.syncProgress, on: self)
            .store(in: &disposeBag)

        appState.$showWidgetSettings
            .receive(on: DispatchQueue.main)
            .assign(to: \.showWidgetSettings, on: self)
            .store(in: &disposeBag)
    }

    func onItemSelected(item: ArchiveItem) {
        selectedItem = item
        showInfoView = true
    }

    func refresh() {
        Task {
            do {
                try await appState.synchronize()
            } catch {
                logger.error("pull to refresh: \(error)")
            }
        }
    }
}
