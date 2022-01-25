import Inject
import Logging
import Foundation

class Synchronization: SynchronizationProtocol {
    private let logger = Logger(label: "synchronization")

    @Inject private var manifestStorage: ManifestStorage
    @Inject private var peripheralArchive: PeripheralArchiveProtocol
    @Inject private var mobileArchive: MobileArchiveProtocol

    func syncWithDevice() async throws {
        let lastManifest = manifestStorage.manifest ?? .init(items: [])

        let mobileChanges = try await mobileArchive
            .manifest
            .changesSince(lastManifest)

        let peripheralChanges = try await peripheralArchive
            .manifest
            .changesSince(lastManifest)

        let actions = resolveActions(
            mobileChanges: mobileChanges,
            peripheralChanges: peripheralChanges)

        for (id, action) in actions {
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
        guard var item = try await peripheralArchive.read(id) else {
            logger.error("invalid item \(id)")
            return
        }
        item.status = .synchronizied
        try await mobileArchive.upsert(item)
    }

    private func updateOnPeripheral(_ id: ArchiveItem.ID) async throws {
        logger.info("update on peripheral \(id)")
        guard var item = try await mobileArchive.read(id) else { return }
        item.status = .synchronizied
        try await peripheralArchive.upsert(item)
        try await mobileArchive.upsert(item)
    }

    private func deleteOnMobile(_ id: ArchiveItem.ID) async throws {
        logger.info("delete on mobile \(id)")
        try await mobileArchive.delete(id)
    }

    private func deleteOnPeripheral(_ id: ArchiveItem.ID) async throws {
        logger.info("delete on peripheral \(id)")
        try await peripheralArchive.delete(id)
        try await mobileArchive.delete(id)
    }

    private func keepBoth(_ id: ArchiveItem.ID) async throws {
        logger.info("keep both \(id)")
        guard let newItem = try await duplicate(id) else {
            return
        }
        try await updateOnPeripheral(newItem.id)
        try await updateOnMobile(id)
    }

    private func duplicate(_ id: ArchiveItem.ID) async throws -> ArchiveItem? {
        guard let item = try await mobileArchive.read(id) else {
            return nil
        }
        let timestamp = Int(Date().timeIntervalSince1970)
        let newName = "\(item.name.value)_\(timestamp)"
        let newItem = item.rename(to: .init(newName))
        try await mobileArchive.upsert(newItem)
        return newItem
    }
}
