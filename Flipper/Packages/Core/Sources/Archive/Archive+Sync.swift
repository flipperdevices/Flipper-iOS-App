import Peripheral

extension Archive {
    func synchronize(_ progress: (Double) -> Void) async throws {
        guard !isLoading else {
            logger.critical("synchronize: archive isn't loaded")
            return
        }
        do {
            try await archiveSync.run(progress)
            try await favoritesSync.run()
            try await updateFavoriteItems()
        } catch {
            logger.critical("synchronize: \(error)")
            throw error
        }
    }

    func cancelSync() {
        archiveSync.cancel()
    }

    func updateFavoriteItems() async throws {
        let favorites = try await mobileFavorites.read()
        _items.value = _items.value.map {
            var item = $0
            item.isFavorite = favorites.contains($0.path)
            return item
        }
    }

    func onSyncEvent(_ event: ArchiveSync.Event) {
        Task {
            do {
                try await handleSyncEvent(event)
            } catch {
                logger.error("event handler: \(error)")
            }
        }
    }

    private func handleSyncEvent(_ event: ArchiveSync.Event) async throws {
        switch event {
        case .syncing(let path):
            setStatus(.synchronizing, for: .init(path: path))
        case .imported(let path):
            if path.isShadowFile {
                if let path = try await originPath(forShadow: path) {
                    try await reload(.init(path: path))
                }
            } else {
                try await reload(.init(path: path))
            }
            setStatus(.synchronized, for: .init(path: path))
        case .exported(let path):
            setStatus(.synchronized, for: .init(path: path))
        case .deleted(let path):
            if path.isShadowFile {
                try await mobileArchive.delete(path)
                if let path = try await originPath(forShadow: path) {
                    try await reload(.init(path: path))
                }
            } else {
                try await delete(.init(path: path))
            }
        }
    }

    // FIXME:
    private func originPath(forShadow path: Path) async throws -> Path? {
        let originPath = Path(string: "\(path.string.dropLast(3))nfc")
        let manifest = try await syncedManifest.get()
        guard manifest[originPath] != nil else {
            return nil
        }
        return originPath
    }
}
