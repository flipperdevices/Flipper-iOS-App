import Inject
import Peripheral
import Foundation
import Logging

class Sync: SyncProtocol {
    private let logger = Logger(label: "synchronization")

    @Inject private var manifestStorage: SyncedManifestStorage
    @Inject private var flipperArchive: FlipperArchiveProtocol
    @Inject private var mobileArchive: MobileArchiveProtocol

    private var eventsSubject: SafeSubject<Event> = .init()
    var events: SafePublisher<Event> { eventsSubject.eraseToAnyPublisher() }

    func syncWithDevice() async throws {
        let lastManifest = manifestStorage.manifest ?? .init([:])

        let mobileChanges = try await mobileArchive
            .manifest
            .changesSince(lastManifest)

        let flipperChanges = try await flipperArchive
            .manifest
            .changesSince(lastManifest)

        let actions = resolveActions(
            mobileChanges: mobileChanges,
            flipperChanges: flipperChanges)

        for (path, action) in actions {
            switch action {
            case .update(.mobile): try await updateOnMobile(path)
            case .delete(.mobile): try await deleteOnMobile(path)
            case .update(.flipper): try await updateOnFlipper(path)
            case .delete(.flipper): try await deleteOnFlipper(path)
            case .conflict: try await keepBoth(path)
            }
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

        eventsSubject.send(.syncing(newPath))
        try await updateOnFlipper(newPath)
        eventsSubject.send(.exported(newPath))

        eventsSubject.send(.syncing(path))
        try await updateOnMobile(path)
        eventsSubject.send(.imported(path))
    }

    // FIXME: refactor
    private func duplicate(_ path: Path) async throws -> Path? {
        guard let filename = path.lastComponent else {
            return nil
        }
        let components = filename.split(separator: ".")
        guard components.count >= 2 else {
            return nil
        }
        let name = components.dropLast().joined(separator: ".")
        let type = components.last.unsafelyUnwrapped
        // TODO: Implement human readable copy name
        let timestamp = Int(Date().timeIntervalSince1970)
        let newFilename = "\(name)_\(timestamp).\(type)"
        let newPath = path.removingLastComponent.appending(newFilename)

        let content = try await mobileArchive.read(path)
        try await mobileArchive.upsert(content, at: newPath)

        return newPath
    }
}
