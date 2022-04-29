import Inject
import Peripheral
import Foundation
import Logging

class ArchiveSync: ArchiveSyncProtocol {
    private let logger = Logger(label: "archive_synchronization")

    @Inject private var manifestStorage: SyncedManifestStorage
    @Inject private var flipperArchive: FlipperArchiveProtocol
    @Inject private var mobileArchive: MobileArchiveProtocol

    private var eventsSubject: SafeSubject<Event> = .init()
    var events: SafePublisher<Event> { eventsSubject.eraseToAnyPublisher() }

    func run(_ progress: (Double) -> Void) async throws {
        let lastManifest = manifestStorage.manifest ?? .init()

        let mobileChanges = try await mobileArchive
            .manifest
            .changesSince(lastManifest)

        let flipperChanges = try await flipperArchive
            .manifest
            .changesSince(lastManifest)

        let actions = resolveActions(
            mobileChanges: mobileChanges,
            flipperChanges: flipperChanges)

        for (index, (path, action)) in actions.enumerated() {
            switch action {
            case .update(.mobile): try await updateOnMobile(path)
            case .delete(.mobile): try await deleteOnMobile(path)
            case .update(.flipper): try await updateOnFlipper(path)
            case .delete(.flipper): try await deleteOnFlipper(path)
            case .conflict: try await keepBoth(path)
            }
            progress(Double(index + 1) / Double(actions.count))
        }

        manifestStorage.manifest = try await mobileArchive.manifest
    }

    private func updateOnMobile(_ path: Path) async throws {
        logger.info("update on mobile \(path)")
        eventsSubject.send(.syncing(path))
        let content = try await flipperArchive.read(path)
        try await mobileArchive.upsert(content, at: path)
        eventsSubject.send(.imported(path))
    }

    private func updateOnFlipper(_ path: Path) async throws {
        logger.info("update on flipper \(path)")
        eventsSubject.send(.syncing(path))
        let content = try await mobileArchive.read(path)
        try await flipperArchive.upsert(content, at: path)
        eventsSubject.send(.exported(path))
    }

    private func deleteOnMobile(_ path: Path) async throws {
        logger.info("delete on mobile \(path)")
        eventsSubject.send(.syncing(path))
        try await mobileArchive.delete(path)
        eventsSubject.send(.deleted(path))
    }

    private func deleteOnFlipper(_ path: Path) async throws {
        logger.info("delete on flipper \(path)")
        eventsSubject.send(.syncing(path))
        try await flipperArchive.delete(path)
        eventsSubject.send(.deleted(path))
    }

    private func keepBoth(_ path: Path) async throws {
        logger.info("keep both \(path)")
        guard let newPath = try await duplicate(path) else {
            return
        }
        try await updateOnFlipper(newPath)
        try await updateOnMobile(path)
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

        while try await mobileArchive.manifest[newFilePath] != nil {
            number += 1
        }

        return newFilePath
    }
}
