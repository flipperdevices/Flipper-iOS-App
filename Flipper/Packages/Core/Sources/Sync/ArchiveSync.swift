import Inject
import Peripheral
import Foundation
import Logging

class ArchiveSync: ArchiveSyncProtocol {
    private let logger = Logger(label: "archive_synchronization")

    @Inject private var manifestStorage: SyncedManifestStorage
    @Inject private var flipperArchive: FlipperArchiveProtocol
    @Inject private var mobileArchive: MobileArchiveProtocol

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
        let lastManifest = manifestStorage.manifest ?? .init()

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

        for (path, action) in actions {
            guard state != .canceled else {
                break
            }
            switch action {
            case .update(.mobile):
                try await updateOnMobile(path) { itemProgress in
                    progress(currentProgress + syncItemFactor * itemProgress)
                }
            case .delete(.mobile):
                try await deleteOnMobile(path) { itemProgress in
                    progress(currentProgress + syncItemFactor * itemProgress)
                }
            case .update(.flipper):
                try await updateOnFlipper(path) { itemProgress in
                    progress(currentProgress + syncItemFactor * itemProgress)
                }
            case .delete(.flipper):
                try await deleteOnFlipper(path) { itemProgress in
                    progress(currentProgress + syncItemFactor * itemProgress)
                }
            case .conflict:
                try await keepBoth(path) { itemProgress in
                    progress(currentProgress + syncItemFactor * itemProgress)
                }
            }
            currentProgress += syncItemFactor
        }

        manifestStorage.manifest = try await mobileArchive.getManifest()
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
        let newPath = try await findNextAvailableName(for: path)
        let content = try await mobileArchive.read(path)
        try await mobileArchive.upsert(content, at: newPath)
        return newPath
    }

    private func findNextAvailableName(for path: Path) async throws -> Path {
        let name = try ArchiveItem.Name(path)
        let type = try ArchiveItem.FileType(path)

        // format: name_{Int}.type
        let parts = name.value.split(separator: "_")
        var number = parts.count >= 2
            ? Int(parts.last.unsafelyUnwrapped) ?? 1
            : 1

        var location: Path { path.removingLastComponent }
        var newFileName: String { "\(name)_\(number).\(type)" }
        var newFilePath: Path { location.appending(newFileName) }

        while try await mobileArchive.getManifest()[newFilePath] != nil {
            number += 1
        }

        return newFilePath
    }
}
