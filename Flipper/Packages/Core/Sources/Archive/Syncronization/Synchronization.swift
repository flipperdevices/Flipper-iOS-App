import Inject
import Logging
import Foundation

class Synchronization: SynchronizationProtocol {
    private let logger = Logger(label: "synchronization")

    @Inject private var manifestStorage: ManifestStorage
    @Inject private var peripheralArchive: PeripheralArchiveProtocol
    @Inject private var mobileArchive: MobileArchiveProtocol

    private var eventsSubject: SafeSubject<Event> = .init()
    var events: SafePublisher<Event> { eventsSubject.eraseToAnyPublisher() }

    func syncWithDevice() async throws {
        let lastManifest = manifestStorage.manifest ?? .init([:])

        let mobileChanges = try await mobileArchive
            .manifest
            .changesSince(lastManifest)

        let peripheralChanges = try await peripheralArchive
            .manifest
            .changesSince(lastManifest)

        let actions = resolveActions(
            mobileChanges: mobileChanges,
            peripheralChanges: peripheralChanges)

        for (path, action) in actions {
            let id: ArchiveItem.ID = .init(path: path)
            switch action {
            case .update(.mobile): try await updateOnMobile(id)
            case .delete(.mobile): try await deleteOnMobile(id)
            case .update(.peripheral): try await updateOnPeripheral(id)
            case .delete(.peripheral): try await deleteOnPeripheral(id)
            case .conflict: try await keepBoth(id)
            }
        }

        manifestStorage.manifest = try await mobileArchive.manifest
    }

    private func updateOnMobile(_ id: ArchiveItem.ID) async throws {
        logger.info("update on mobile \(id)")
        var item = try await peripheralArchive.read(id)
        if try await mobileArchive.manifest[id.path] != nil {
            item.note = try await mobileArchive.read(id).note
        }
        try await mobileArchive.upsert(item)
        eventsSubject.send(.imported(id))
    }

    private func updateOnPeripheral(_ id: ArchiveItem.ID) async throws {
        logger.info("update on peripheral \(id)")
        let item = try await mobileArchive.read(id)
        try await peripheralArchive.upsert(item)
        eventsSubject.send(.exported(item.id))
    }

    private func deleteOnMobile(_ id: ArchiveItem.ID) async throws {
        logger.info("delete on mobile \(id)")
        try await mobileArchive.delete(id)
        eventsSubject.send(.deleted(id))
    }

    private func deleteOnPeripheral(_ id: ArchiveItem.ID) async throws {
        logger.info("delete on peripheral \(id)")
        try await peripheralArchive.delete(id)
        eventsSubject.send(.deleted(id))
    }

    private func keepBoth(_ id: ArchiveItem.ID) async throws {
        logger.info("keep both \(id)")
        guard let newItem = try await duplicate(id) else {
            return
        }

        try await updateOnPeripheral(newItem.id)
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

extension Synchronization {
    func status(for item: ArchiveItem) -> ArchiveItem.Status {
        guard let hash = manifestStorage.manifest?[item.path] else {
            return .imported
        }
        return hash == item.hash ? .synchronized : .modified
    }
}
