import Inject
import Analytics

import Combine
import Logging
import Foundation

@MainActor
public class ArchiveService: ObservableObject {
    let appState: AppState
    let syncService: SyncService

    @Inject var archive: Archive
    private var disposeBag: DisposeBag = .init()

    @Published public private(set) var items: [ArchiveItem] = []
    @Published public private(set) var deleted: [ArchiveItem] = []

    public let imported = SafeSubject<ArchiveItem>()

    public init(appState: AppState, syncService: SyncService) {
        self.appState = appState
        self.syncService = syncService
        subscribeToPublishers()
    }

    func subscribeToPublishers() {
        archive.items
            .receive(on: DispatchQueue.main)
            .assign(to: \.items, on: self)
            .store(in: &disposeBag)

        archive.deletedItems
            .receive(on: DispatchQueue.main)
            .assign(to: \.deleted, on: self)
            .store(in: &disposeBag)
    }

    public func save(
        _ item: ArchiveItem,
        as newItem: ArchiveItem
    ) async throws {
        do {
            if item.name != newItem.name {
                try await archive.rename(item.id, to: newItem.name)
            }
            try await archive.upsert(newItem)
            recordEdit()
            syncService.synchronize()
        } catch {
            logger.error("saving changes: \(error)")
            throw error
        }
    }

    public func delete(_ item: ArchiveItem) async throws {
        do {
            try await archive.delete(item.id)
            syncService.synchronize()
        } catch {
            logger.error("deleting item: \(error)")
            throw error
        }
    }

    public func restore(_ item: ArchiveItem) async throws {
        do {
            try await archive.restore(item)
            syncService.synchronize()
        } catch {
            logger.error("restore item: \(error)")
            throw error
        }
    }

    public func wipe(_ item: ArchiveItem) async throws {
        do {
            try await archive.wipe(item)
        } catch {
            logger.error("wipe item: \(error)")
            throw error
        }
    }

    public func onIsFavoriteToggle(_ item: ArchiveItem) async throws {
        do {
            try await archive.onIsFavoriteToggle(item.path)
        } catch {
            logger.error("toggling favorite: \(error)")
            throw error
        }
    }

    public func add(_ item: ArchiveItem) async throws {
        do {
            try await archive.importKey(item)
            logger.info("added: \(item.filename)")
            imported.send(item)
            recordImport()
            syncService.synchronize()
        } catch {
            logger.error("add: \(error)")
            throw error
        }
    }

    public func loadItem(url: URL) async throws -> ArchiveItem {
        let item = try await Sharing.importKey(from: url)
        return try await archive.copyIfExists(item)
    }

    public func restoreAll() {
        Task {
            do {
                try await archive.restoreAll()
                syncService.synchronize()
            } catch {
                logger.error("restore all: \(error)")
            }
        }
    }

    public func deleteAll() {
        Task {
            do {
                try await archive.wipeAll()
            } catch {
                logger.error("delete all: \(error)")
            }
        }
    }

    public func backupKeys() {
        archive.backupKeys()
    }

    // MARK: Analytics

    func recordEdit() {
        analytics.appOpen(target: .keyEdit)
    }

    func recordImport() {
        analytics.appOpen(target: .keyImport)
    }
}
