import Inject
import Combine
import Foundation
import Peripheral
import Logging

public class Archive: ObservableObject {
    public static let shared: Archive = .init()
    let logger = Logger(label: "archive")

    @Inject var archiveSync: ArchiveSyncProtocol
    @Inject var favoritesSync: FavoritesSyncProtocol

    @Inject var mobileFavorites: MobileFavoritesProtocol
    @Inject var mobileArchive: MobileArchiveProtocol
    @Inject var mobileNotes: MobileNotesStorage
    @Inject var deletedArchive: DeletedArchiveProtocol
    @Inject var manifestStorage: SyncedManifestStorage

    @Published public var items: [ArchiveItem] = []
    @Published public var deletedItems: [ArchiveItem] = []

    @Published public var isLoading = false

    private var disposeBag: DisposeBag = .init()

    public enum Error: String, Swift.Error {
        case alreadyExists
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
        isLoading = true
        Task {
            do {
                items = try await loadItems(
                    from: mobileArchive,
                    loadItem: loadArchiveItem)
                deletedItems = try await loadItems(
                    from: deletedArchive,
                    loadItem: loadDeletedItem)
                isLoading = false
            } catch {
                logger.critical("loading archive: \(error)")
            }
        }
    }

    private func loadItems(
        from archive: ArchiveProtocol,
        loadItem: (Path, ArchiveProtocol) async throws -> ArchiveItem
    ) async throws -> [ArchiveItem] {
        var items = [ArchiveItem]()
        let paths = try await archive.getManifest().paths.filter {
            !$0.isShadowFile
        }
        for path in paths {
            do {
                items.append(try await loadItem(path, archive))
            } catch {
                logger.error("load key: \(path)")
            }
        }
        return items
    }

    private func readItem(
        at path: Path,
        from archive: ArchiveProtocol
    ) async throws -> ArchiveItem {
        let content = try await archive.read(path)
        var item = try ArchiveItem(path: path, content: content)
        if let path = item.shadowPath {
            let content = (try? await archive.read(path)) ?? ""
            item.shadowCopy = .init(content: content) ?? []
        }
        return item
    }

    private func loadArchiveItem(
        at path: Path,
        from archive: ArchiveProtocol
    ) async throws -> ArchiveItem {
        var item = try await readItem(at: path, from: archive)
        item.status = status(for: item)
        item.isFavorite = (try await mobileFavorites.read()).contains(item.path)
        item.note = try await loadNote(for: item.path)
        return item
    }

    private func loadDeletedItem(
        at path: Path,
        from archive: ArchiveProtocol
    ) async throws -> ArchiveItem {
        var item = try await readItem(at: path, from: archive)
        item.status = .deleted
        return item
    }

    private func loadNote(for path: Path) async throws -> String {
        (try? await mobileNotes.get(path)) ?? ""
    }
}

// MARK: Actions

extension Archive {
    public func get(_ id: ArchiveItem.ID) -> ArchiveItem? {
        items.first { $0.id == id }
    }

    public func upsert(_ item: ArchiveItem) async throws {
        try await mobileArchive.upsert(item.content, at: item.path)
        if let path = item.shadowPath {
            item.shadowCopy.isEmpty
                ? try await mobileArchive.delete(path)
                : try await mobileArchive.upsert(item.shadowContent, at: path)
        }
        try await mobileNotes.upsert(item.note, at: item.path)
        items.removeAll { $0.path == item.path }
        items.append(item)
    }

    public func reload(_ id: ArchiveItem.ID) async throws {
        let item = try await loadArchiveItem(at: id.path, from: mobileArchive)
        items.removeAll { $0.path == item.path }
        items.append(item)
    }

    public func delete(_ id: ArchiveItem.ID) async throws {
        if var item = get(id) {
            item.note = ""
            item.isFavorite = false
            try await backup(item)
            try await mobileNotes.delete(item.path)
            try await removeFavorite(for: item.path)
            try await mobileArchive.delete(item.path)
            if let shadowPath = item.shadowPath {
                try await mobileArchive.delete(shadowPath)
            }
            items.removeAll { $0.path == item.path }
        }
    }

    private func backup(_ item: ArchiveItem) async throws {
        var item = item
        item.status = .deleted
        try await deletedArchive.upsert(item.content, at: item.path)
        if let shadowPath = item.shadowPath {
            try await deletedArchive.upsert(item.shadowContent, at: shadowPath)
        }
        deletedItems.removeAll { $0.path == item.path }
        deletedItems.append(item)
    }

    public func copyIfExists(_ item: ArchiveItem) async throws -> ArchiveItem {
        let path = try await mobileArchive.nextAvailablePath(for: item.path)
        return try ArchiveItem(
            filename: path.lastComponent ?? "",
            properties: item.properties,
            shadowCopy: item.shadowCopy)
    }

    public func restore(_ item: ArchiveItem) async throws {
        var item = try await copyIfExists(item)
        item.status = status(for: item)
        try await upsert(item)
        try await wipe(item)
    }

    public func restoreAll() async throws {
        for item in deletedItems {
            try await restore(item)
        }
    }

    public func wipe(_ item: ArchiveItem) async throws {
        try await deletedArchive.delete(item.path)
        if let shadowPath = item.shadowPath {
            try await deletedArchive.delete(shadowPath)
        }
        deletedItems.removeAll { $0.path == item.path }
    }

    public func wipeAll() async throws {
        for item in deletedItems {
            try await wipe(item)
        }
    }

    public func onIsFavoriteToggle(_ path: Path) async throws {
        guard let index = items.firstIndex(where: { $0.path == path }) else {
            return
        }
        items[index].isFavorite = try await toggleFavorite(for: path)
        try await favoritesSync.run()
    }

    @discardableResult
    private func toggleFavorite(for path: Path) async throws -> Bool {
        var favorites = try await mobileFavorites.read()
        favorites.toggle(path)
        try await mobileFavorites.write(favorites)
        return favorites.contains(path)
    }

    private func upsertFavorite(for path: Path) async throws {
        var favorites = try await mobileFavorites.read()
        favorites.upsert(path)
        try await mobileFavorites.write(favorites)
    }

    private func removeFavorite(for path: Path) async throws {
        var favorites = try await mobileFavorites.read()
        favorites.delete(path)
        try await mobileFavorites.write(favorites)
    }
}

extension Archive {
    public func rename(
        _ id: ArchiveItem.ID,
        to name: ArchiveItem.Name
    ) async throws {
        if let item = get(id) {
            let newItem = item.rename(to: name)
            guard get(newItem.id) == nil else {
                throw Error.alreadyExists
            }
            try await mobileArchive.delete(item.path)
            if let shadowPath = item.shadowPath {
                try? await mobileArchive.delete(shadowPath)
            }
            if item.isFavorite {
                try await removeFavorite(for: item.path)
                try await upsertFavorite(for: newItem.path)
            }
            try await mobileNotes.delete(item.path)
            try await mobileArchive.upsert(newItem.content, at: newItem.path)
            try await mobileNotes.upsert(newItem.content, at: newItem.path)
            if let shadowPath = newItem.shadowPath {
                try await mobileArchive.upsert(
                    newItem.shadowContent,
                    at: shadowPath)
            }
            items.removeAll { $0.path == item.path }
            items.append(newItem)
        }
    }
}

extension Archive {
    public func status(for item: ArchiveItem) -> ArchiveItem.Status {
        guard let hash = manifestStorage.manifest?[item.path] else {
            return .imported
        }
        return hash == item.hash ? .synchronized : .modified
    }

    public func setStatus(
        _ status: ArchiveItem.Status,
        for id: ArchiveItem.ID
    ) {
        if let index = items.firstIndex(where: { $0.path == id.path }) {
            items[index].status = status
        }
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
        case .alreadyExists:
            return "The name is already taken. Please choose a different name."
        }
    }
}
