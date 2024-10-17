import Peripheral
import Foundation

extension Archive {
    func synchronize(
        _ progress: (Synchronization.Progress) -> Void
    ) async throws -> Int {
        guard !isLoading else {
            logger.critical("synchronize: archive isn't loaded")
            return 0
        }
        do {
            let changesCount = try await archiveSync.run(progress)
            try await favoritesSync.run()
            try await updateFavoriteItems()
            return changesCount
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
            if path.isShadowFile || path.isLayoutFile {
                try await reloadOrigin(for: path)
            } else {
                try await reload(.init(path: path))
            }
            setStatus(.synchronized, for: .init(path: path))
        case .exported(let path):
            setStatus(.synchronized, for: .init(path: path))
        case .deleted(let path):
            if path.isShadowFile || path.isLayoutFile {
                try await mobileArchive.delete(path)
                try await reloadOrigin(for: path)
            } else {
                try await delete(.init(path: path))
            }
        case .synced(let path):
            setStatus(.synchronized, for: .init(path: path))
        }
    }

    // TODO: do not reload origin if doesn't exist yet
    private func reloadOrigin(for path: Path) async throws {
        do {
            let path = originPath(for: path)
            try await reload(.init(path: path))
        } catch let error as NSError where error.code == 260 {
            logger.info("orphan \(path) file loaded")
        }
    }

    private func originPath(for path: Path) -> Path {
        guard
            let filename = path.lastComponent,
            let fileType = FileType(filename: filename),
            let origin = fileType.origin
        else {
            return path
        }
        return .init(string: path.string
            .dropLast(fileType.extension.count)
            .appending(origin.extension))
    }
}
