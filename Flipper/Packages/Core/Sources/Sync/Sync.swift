import Inject
import Logging
import Foundation

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
            let id: ArchiveItem.ID = .init(path: path)
            switch action {
            case .update(.mobile): try await updateOnMobile(id)
            case .delete(.mobile): try await deleteOnMobile(id)
            case .update(.flipper): try await updateOnFlipper(id)
            case .delete(.flipper): try await deleteOnFlipper(id)
            case .conflict: try await keepBoth(id)
            }
        }

        manifestStorage.manifest = try await mobileArchive.manifest
    }

    private func updateOnMobile(_ id: ArchiveItem.ID) async throws {
        logger.info("update on mobile \(id)")
        var item = try await flipperArchive.read(id)
        if try await mobileArchive.manifest[id.path] != nil {
            item.note = try await mobileArchive.read(id).note
        }
        try await mobileArchive.upsert(item)
        eventsSubject.send(.imported(id))
    }

    private func updateOnFlipper(_ id: ArchiveItem.ID) async throws {
        logger.info("update on flipper \(id)")
        let item = try await mobileArchive.read(id)
        try await flipperArchive.upsert(item)
        eventsSubject.send(.exported(item.id))
    }

    private func deleteOnMobile(_ id: ArchiveItem.ID) async throws {
        logger.info("delete on mobile \(id)")
        try await mobileArchive.delete(id)
        eventsSubject.send(.deleted(id))
    }

    private func deleteOnFlipper(_ id: ArchiveItem.ID) async throws {
        logger.info("delete on flipper \(id)")
        try await flipperArchive.delete(id)
        eventsSubject.send(.deleted(id))
    }

    private func keepBoth(_ id: ArchiveItem.ID) async throws {
        logger.info("keep both \(id)")
        guard let newItem = try await duplicate(id) else {
            return
        }

        try await updateOnFlipper(newItem.id)
        eventsSubject.send(.exported(newItem.id))

        try await updateOnMobile(id)
        eventsSubject.send(.imported(id))
    }

    private func duplicate(_ id: ArchiveItem.ID) async throws -> ArchiveItem? {
        let item = try await mobileArchive.read(id)
        // TODO: Implement human readable copy name
        let timestamp = Int(Date().timeIntervalSince1970)
        let newName = "\(item.name.value)_\(timestamp)"
        let newItem = item.rename(to: .init(newName))
        try await mobileArchive.upsert(newItem)
        return newItem
    }
}

extension Sync {
    func status(for item: ArchiveItem) -> ArchiveItem.Status {
        guard let hash = manifestStorage.manifest?[item.path] else {
            return .imported
        }
        return hash == item.hash ? .synchronized : .modified
    }
}
