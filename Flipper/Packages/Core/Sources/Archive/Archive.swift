import Peripheral

import Combine

public class Archive {
    let archiveSync: ArchiveSyncProtocol
    let favoritesSync: FavoritesSyncProtocol

    let mobileFavorites: FavoritesProtocol
    let mobileArchive: ArchiveProtocol & Compressable
    let mobileNotes: ArchiveStorage
    let deletedArchive: ArchiveProtocol

    let syncedManifest: ManifestStorage

    init(
        archiveSync: ArchiveSyncProtocol,
        favoritesSync: FavoritesSyncProtocol,
        mobileFavorites: FavoritesProtocol,
        mobileArchive: ArchiveProtocol & Compressable,
        mobileNotes: ArchiveStorage,
        deletedArchive: ArchiveProtocol,
        syncedManifest: ManifestStorage
    ) {
        self.archiveSync = archiveSync
        self.favoritesSync = favoritesSync
        self.mobileFavorites = mobileFavorites
        self.mobileArchive = mobileArchive
        self.mobileNotes = mobileNotes
        self.deletedArchive = deletedArchive
        self.syncedManifest = syncedManifest

        // FIXME:

        archiveSync.events
            .sink { [weak self] in
                self?.onSyncEvent($0)
            }
            .store(in: &cancellables)

        load()
    }

    private var cancellables: [AnyCancellable] = .init()

    public enum Error: String, Swift.Error {
        case alreadyExists
    }

    public var items: AnyPublisher<[ArchiveItem], Never> {
        _items.eraseToAnyPublisher()
    }
    var _items: CurrentValueSubject<[ArchiveItem], Never> = {
        .init([])
    }()

    public var deletedItems: AnyPublisher<[ArchiveItem], Never> {
        _deletedItems.eraseToAnyPublisher()
    }
    var _deletedItems: CurrentValueSubject<[ArchiveItem], Never> = {
        .init([])
    }()

    var isLoading = false

    func load() {
        isLoading = true
        Task {
            do {
                _items.value = try await loadItems(
                    from: mobileArchive,
                    loadItem: loadArchiveItem)
                _deletedItems.value = try await loadItems(
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
        item.status = try await status(for: item)
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
        _items.value.first { $0.id == id }
    }

    public func upsert(_ item: ArchiveItem) async throws {
        try await mobileArchive.upsert(item.content, at: item.path)
        if let path = item.shadowPath {
            item.shadowCopy.isEmpty
                ? try await mobileArchive.delete(path)
                : try await mobileArchive.upsert(item.shadowContent, at: path)
        }
        try await mobileNotes.upsert(item.note, at: item.path)
        _items.value.removeAll { $0.path == item.path }
        _items.value.append(item)
    }

    public func reload(_ id: ArchiveItem.ID) async throws {
        let item = try await loadArchiveItem(at: id.path, from: mobileArchive)
        _items.value.removeAll { $0.path == item.path }
        _items.value.append(item)
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
            _items.value.removeAll { $0.path == item.path }
        }
    }

    private func backup(_ item: ArchiveItem) async throws {
        var item = item
        item.status = .deleted
        try await deletedArchive.upsert(item.content, at: item.path)
        if let shadowPath = item.shadowPath {
            try await deletedArchive.upsert(item.shadowContent, at: shadowPath)
        }
        _deletedItems.value.removeAll { $0.path == item.path }
        _deletedItems.value.append(item)
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
        item.status = try await status(for: item)
        try await upsert(item)
        try await wipe(item)
    }

    public func restoreAll() async throws {
        for item in _deletedItems.value {
            try await restore(item)
        }
    }

    public func wipe(_ item: ArchiveItem) async throws {
        try await deletedArchive.delete(item.path)
        if let shadowPath = item.shadowPath {
            try await deletedArchive.delete(shadowPath)
        }
        _deletedItems.value.removeAll { $0.path == item.path }
    }

    public func wipeAll() async throws {
        for item in _deletedItems.value {
            try await wipe(item)
        }
    }

    public func onIsFavoriteToggle(_ path: Path) async throws {
        guard let index = _items.value.firstIndex(
            where: { $0.path == path }
        ) else {
            return
        }
        _items.value[index].isFavorite = try await toggleFavorite(for: path)
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
                throw Archive.Error.alreadyExists
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
            _items.value.removeAll { $0.path == item.path }
            _items.value.append(newItem)
        }
    }
}

extension Archive {
    public func status(
        for item: ArchiveItem
    ) async throws -> ArchiveItem.Status {
        let syncedManifest = try await syncedManifest.get()
        guard let synced = syncedManifest[item.path] else {
            return .imported
        }

        let mobileManifest = try await mobileArchive.getManifest()
        guard let current = mobileManifest[item.path] else {
            return .imported
        }

        return synced == current ? .synchronized : .modified
    }

    public func setStatus(
        _ status: ArchiveItem.Status,
        for id: ArchiveItem.ID
    ) {
        if let index = _items.value.firstIndex(where: { $0.path == id.path }) {
            _items.value[index].status = status
        }
    }
}

extension Archive {
    func importKey(_ item: ArchiveItem) async throws {
        if !_items.value.contains(where: { item.path == $0.path }) {
            try await upsert(item)
        } else {
            throw Error.alreadyExists
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
