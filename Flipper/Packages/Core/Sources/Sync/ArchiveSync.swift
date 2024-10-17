import Peripheral

import Combine
import OrderedCollections

class ArchiveSync: ArchiveSyncProtocol {
    private let flipperArchive: ArchiveProtocol
    private let mobileArchive: ArchiveProtocol
    private let syncedManifest: ManifestStorage

    init(
        flipperArchive: ArchiveProtocol,
        mobileArchive: ArchiveProtocol,
        syncedManifest: ManifestStorage
    ) {
        self.flipperArchive = flipperArchive
        self.mobileArchive = mobileArchive
        self.syncedManifest = syncedManifest
    }

    private var state: State = .idle
    private var eventsSubject: PassthroughSubject<Event, Never> = {
        .init()
    }()
    var events: AnyPublisher<Event, Never> {
        eventsSubject.eraseToAnyPublisher()
    }

    enum State {
        case idle
        case running
        case canceled
    }

    func run(
        _ progress: (Synchronization.Progress) -> Void
    ) async throws -> Int {
        guard state == .idle else { return 0 }
        state = .running
        defer { state = .idle }
        return try await sync(progress)
    }

    var manifestProgressFactor: Double { 0.5 }
    var syncProgressFactor: Double { 1.0 - manifestProgressFactor }

    private func sync(
        _ progress: (Synchronization.Progress) -> Void
    ) async throws -> Int {
        let lastManifest = try await syncedManifest.get()

        let mobileChanges = try await mobileArchive
            .getManifest()
            .changesSince(lastManifest)

        let flipperChanges = try await flipperArchive
            .getManifest { manifestProgress in
                let value = manifestProgress * manifestProgressFactor
                progress(.syncManifest(value))
            }
            .changesSince(lastManifest)

        let actions = resolveActions(
            mobileChanges: mobileChanges,
            flipperChanges: flipperChanges)

        guard !actions.isEmpty else {
            try await syncedManifest.upsert(mobileArchive.getManifest())
            progress(.done)
            return 0
        }

        let syncItemFactor = syncProgressFactor / Double(actions.count)
        var currentProgress = manifestProgressFactor

        func preciseProgress(_ itemProgress: Double, _ path: Path) {
            let value = currentProgress + syncItemFactor * itemProgress

            // FIXME: find the issue (very rare)
            guard value.isNormal else { return }

            progress(.syncFile(value, path.lastComponent ?? path.description))
        }

        // NOTE: Flipper's filesystem is case-insensitive,
        // so we should delete the key first
        let sortedActions = sortActions(actions)

        for (path, action) in sortedActions {
            guard state != .canceled else {
                break
            }
            switch action {
            case .update(.mobile):
                try await updateOnMobile(path) { preciseProgress($0, path) }
            case .delete(.mobile):
                try await deleteOnMobile(path) { preciseProgress($0, path) }
            case .update(.flipper):
                try await updateOnFlipper(path) { preciseProgress($0, path) }
            case .delete(.flipper):
                try await deleteOnFlipper(path) { preciseProgress($0, path) }
            case .conflict:
                path.isShadowFile || path.isLayoutFile
                    ? try await updateOnMobile(path) {
                        preciseProgress($0, path)
                    }
                    : try await keepBoth(path) { preciseProgress($0, path) }
            case .skip:
                try await markSynced(path) { preciseProgress($0, path) }
            }
            currentProgress += syncItemFactor
        }

        try await syncedManifest.upsert(mobileArchive.getManifest())

        return actions.count
    }

    private func sortActions(
        _ actions: [Path: Action]
    ) -> OrderedDictionary<Path, Action> {
        var orderedActions = OrderedDictionary<Path, Action>(
            uniqueKeysWithValues: actions
        )
        orderedActions.sort { first, second in
            switch (first.value, second.value) {
            case (.delete, _): return true
            default: return false
            }
        }
        return orderedActions
    }

    func cancel() {
        state = .canceled
    }

    private func updateOnMobile(
        _ path: Path,
        progress: (Double) -> Void
    ) async throws {
        logger.info("update on mobile \(path)")
        eventsSubject.send(.syncing(path))
        let content = try await flipperArchive.read(path, progress: progress)
        try await mobileArchive.upsert(content, at: path)
        eventsSubject.send(.imported(path))
    }

    private func updateOnFlipper(
        _ path: Path,
        progress: (Double) -> Void
    ) async throws {
        logger.info("update on flipper \(path)")
        eventsSubject.send(.syncing(path))
        let content = try await mobileArchive.read(path)
        try await flipperArchive.upsert(content, at: path, progress: progress)
        eventsSubject.send(.exported(path))
    }

    private func deleteOnMobile(
        _ path: Path,
        progress: (Double) -> Void
    ) async throws {
        logger.info("delete on mobile \(path)")
        eventsSubject.send(.syncing(path))
        try await mobileArchive.delete(path)
        progress(1)
        eventsSubject.send(.deleted(path))
    }

    private func deleteOnFlipper(
        _ path: Path,
        progress: (Double) -> Void
    ) async throws {
        logger.info("delete on flipper \(path)")
        eventsSubject.send(.syncing(path))
        try await flipperArchive.delete(path)
        progress(1)
        eventsSubject.send(.deleted(path))
    }

    private func keepBoth(
        _ path: Path,
        progress: (Double) -> Void
    ) async throws {
        logger.info("keep both \(path)")
        guard let newPath = try await duplicate(path) else {
            return
        }
        try await updateOnFlipper(newPath) {
            progress($0 / 2)
        }
        try await updateOnMobile(path) {
            progress(0.5 + $0 / 2)
        }
    }

    private func markSynced(
        _ path: Path,
        progress: (Double) -> Void
    ) async throws {
        eventsSubject.send(.synced(path))
        progress(1)
    }

    // MARK: Duplicating item

    private func duplicate(_ path: Path) async throws -> Path? {
        let newPath = try await mobileArchive.nextAvailablePath(for: path)
        let content = try await mobileArchive.read(path)
        try await mobileArchive.upsert(content, at: newPath)
        return newPath
    }
}

extension Path {
    var isShadowFile: Bool {
        guard let filename = lastComponent else { return false }
        return filename.hasSuffix(FileType.shadow.extension)
    }

    var isLayoutFile: Bool {
        guard let filename = lastComponent else { return false }
        return filename.hasSuffix(FileType.infraredUI.extension)
    }
}
