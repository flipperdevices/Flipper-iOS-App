import Inject
import Combine
import Foundation
import Peripheral
import Logging

public class Archive: ObservableObject {
    public static let shared: Archive = .init()
    let logger = Logger(label: "archive")

    @Inject var archiveSync: ArchiveSyncProtocol

    @Inject var mobileFavorites: MobileFavoritesProtocol
    @Inject var mobileArchive: MobileArchiveProtocol
    @Inject var deletedArchive: DeletedArchiveProtocol
    @Inject var manifestStorage: SyncedManifestStorage

    @Published public var items: [ArchiveItem] = []
    @Published public var deletedItems: [ArchiveItem] = []

    @Published public var isSyncronizing = false

    private var disposeBag: DisposeBag = .init()

    public enum Error: String, Swift.Error {
        case alredyExists
    }

    private init() {
        archiveSync.events
            .sink { [weak self] in
                self?.onSyncEvent($0)
            }
            .store(in: &disposeBag)

        load()
    }

    func load() {
        isSyncronizing = true
        Task {
            items = try await loadArchive()
            deletedItems = try await loadDeleted()
            isSyncronizing = false
        }
    }

    func loadArchive() async throws -> [ArchiveItem] {
        var items = [ArchiveItem]()
        let favorites = try await mobileFavorites.read()
        for path in try await mobileArchive.manifest.paths {
            let content = try await mobileArchive.read(path)
            var item = try ArchiveItem(path: path, content: content)
            item.status = status(for: item)
            item.isFavorite = favorites.contains(item.path)
            items.append(item)
        }
        return items
    }

    func loadDeleted() async throws -> [ArchiveItem] {
        var items = [ArchiveItem]()
        for path in try await deletedArchive.manifest.paths {
            let content = try await deletedArchive.read(path)
            let item = try ArchiveItem(path: path, content: content)
            items.append(item)
        }
        return items
    }
}

extension Archive {
    public func get(_ id: ArchiveItem.ID) -> ArchiveItem? {
        items.first { $0.id == id }
    }

    public func upsert(_ item: ArchiveItem) async throws {
        try await mobileArchive.upsert(item.content, at: item.path)
        items.removeAll { $0.path == item.path }
        var item = item
        item.status = status(for: item)
        items.append(item)
    }

    public func delete(_ id: ArchiveItem.ID) async throws {
        if let item = get(id) {
            try await backup(item)
            try await mobileArchive.delete(item.path)
            items.removeAll { $0.path == item.path }
        }
    }

    public func toggleFavorite(_ path: Path) async throws {
        guard let index = items.firstIndex(where: { $0.path == path }) else {
            return
        }
        var favorites = try await mobileFavorites.read()
        favorites.toggle(path)
        try await mobileFavorites.write(favorites)
        items[index].isFavorite = favorites.contains(path)
    }
}

extension Archive {
    public func wipe(_ path: Path) async throws {
        try await deletedArchive.delete(path)
        deletedItems.removeAll { $0.path == path }
    }

    public func wipeAll() async throws {
        for item in deletedItems {
            try await deletedArchive.delete(item.path)
        }
        deletedItems.removeAll()
    }

    public func rename(_ id: ArchiveItem.ID, to name: ArchiveItem.Name) async throws {
        if let item = get(id) {
            let newItem = item.rename(to: name)
            guard get(newItem.id) == nil else {
                throw Error.alredyExists
            }
            try await mobileArchive.delete(item.path)
            items.removeAll { $0.path == item.path }
            try await mobileArchive.upsert(newItem.content, at: newItem.path)
            items.append(newItem)
        }
    }

    func backup(_ item: ArchiveItem) async throws {
        try await deletedArchive.upsert(item.content, at: item.path)
        deletedItems.removeAll { $0.path == item.path }
        deletedItems.append(item)
    }

    public func restore(_ item: ArchiveItem) async throws {
        let manifest = try await mobileArchive.manifest
        // TODO: resolve conflicts
        guard manifest[item.path] == nil else {
            logger.error("alredy exists")
            return
        }
        var item = item
        item.status = status(for: item)
        try await mobileArchive.upsert(item.content, at: item.path)
        items.append(item)

        try await deletedArchive.delete(item.path)
        deletedItems.removeAll { $0.path == item.path }
    }
}

extension Archive {
    public func status(for item: ArchiveItem) -> ArchiveItem.Status {
        guard let hash = manifestStorage.manifest?[item.path] else {
            return .imported
        }
        return hash == item.hash ? .synchronized : .modified
    }
}

extension Archive {
    func importKey(_ item: ArchiveItem) async throws {
        if !items.contains(where: { item.path == $0.path }) {
            try await upsert(item)
        }
    }
}

extension Archive.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .alredyExists:
            return "The name is already taken. Please choose a different name."
        }
    }
}
