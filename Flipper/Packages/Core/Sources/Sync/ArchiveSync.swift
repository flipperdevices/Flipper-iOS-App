import Inject
import Logging
import Peripheral
import Foundation
import OrderedCollections

class ArchiveSync: ArchiveSyncProtocol {
    @Inject private var flipperArchive: FlipperArchiveProtocol
    @Inject private var mobileArchive: MobileArchiveProtocol
    @Inject private var syncedItems: SyncedItemsProtocol

    private var state: State = .idle
    private var eventsSubject: SafeSubject<Event> = .init()
    var events: SafePublisher<Event> { eventsSubject.eraseToAnyPublisher() }

    enum State {
        case idle
        case running
        case canceled
    }

    func run(_ progress: (Double) -> Void) async throws {
        guard state == .idle else { return }
        state = .running
        defer { state = .idle }
        progress(0)
        try await sync(progress)
    }

    var manifestProgressFactor: Double { 0.5 }
    var syncProgressFactor: Double { 1.0 - manifestProgressFactor }

    private func sync(_ progress: (Double) -> Void) async throws {
        let lastManifest = syncedItems.manifest ?? .init()

        let mobileChanges = try await mobileArchive
            .getManifest()
            .changesSince(lastManifest)

        let flipperChanges = try await flipperArchive
            .getManifest { manifestProgress in
                progress(manifestProgress * manifestProgressFactor)
            }
            .changesSince(lastManifest)

        let actions = resolveActions(
            mobileChanges: mobileChanges,
            flipperChanges: flipperChanges)

        let syncItemFactor = syncProgressFactor / Double(actions.count)
        var currentProgress = manifestProgressFactor

        func preciseProgress(_ itemProgress: Double) {
            progress(currentProgress + syncItemFactor * itemProgress)
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
                try await updateOnMobile(path, progress: preciseProgress)
            case .delete(.mobile):
                try await deleteOnMobile(path, progress: preciseProgress)
            case .update(.flipper):
                try await updateOnFlipper(path, progress: preciseProgress)
            case .delete(.flipper):
                try await deleteOnFlipper(path, progress: preciseProgress)
            case .conflict:
                path.isShadowFile
                    ? try await updateOnMobile(path, progress: preciseProgress)
                    : try await keepBoth(path, progress: preciseProgress)
            }
            currentProgress += syncItemFactor
        }

        syncedItems.manifest = try await mobileArchive.getManifest()
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
}
