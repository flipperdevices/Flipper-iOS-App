import Inject
import Logging

// swiftlint:disable nesting cyclomatic_complexity

class Synchronization: SynchronizationProtocol {
    private let logger = Logger(label: "synchronization")

    enum ItemStatus: Equatable {
        case deleted
        case modified(Hash)
    }

    enum Action {
        case conflict
        case update(Target)
        case delete(Target)

        enum Target {
            case mobile
            case peripheral
        }
    }

    @Inject private var manifestStorage: ManifestStorage
    @Inject private var peripheralArchive: PeripheralArchive
    private var archive: Archive { .shared }

    func syncWithDevice() async throws {
        let lastManifest = manifestStorage.manifest ?? .init(items: [])
        let mobileChanges = getMobileState(using: lastManifest)
        let peripheralChanges = try await getPeripheralState(using: lastManifest)
        let result = planSync(
            mobileChanges: mobileChanges,
            peripheralChanges: peripheralChanges)

        // sync changes

        func updateOnMobile(at path: Path) async throws {
            logger.info("update on mobile \(path)")
            guard let item = try await peripheralArchive.read(at: path) else {
                logger.error("invalid item at \(path)")
                return
            }
            archive.upsert(item)
            archive.updateStatus(of: item, to: .synchronizied)
        }

        func updateOnPeripheral(at path: Path) async throws {
            logger.info("update on peripheral \(path)")
            guard let item = archive.items.first(where: { $0.path == path })
            else { return }
            try await peripheralArchive.write(item)
            archive.updateStatus(of: item, to: .synchronizied)
        }

        func deleteOnMobile(at path: Path) async throws {
            logger.info("delete on mobile \(path)")
            archive.delete(.init(path: path))
        }

        func deleteOnPeripheral(at path: Path) async throws {
            logger.info("delete on peripheral \(path)")
            try await peripheralArchive.delete(at: path)
            archive.delete(.init(path: path))
        }

        func keepBoth(at path: Path) async throws {
            logger.info("keep both \(path)")
            guard let newItem = archive.duplicate(.init(path: path)) else {
                return
            }
            try await updateOnPeripheral(at: newItem.path)
            try await updateOnMobile(at: path)
        }

        for (path, action) in result {
            switch action {
            case .update(.mobile): try await updateOnMobile(at: path)
            case .delete(.mobile): try await deleteOnMobile(at: path)
            case .update(.peripheral): try await updateOnPeripheral(at: path)
            case .delete(.peripheral): try await deleteOnPeripheral(at: path)
            case .conflict: try await keepBoth(at: path)
            }
        }

        manifestStorage.manifest = archive.getManifest()
    }

    func getMobileState(using manifest: Manifest) -> [Path: ItemStatus] {
        let mobileManifest = archive.getManifest()
        return mobileManifest.changesSince(manifest)
    }

    func getPeripheralState(
        using manifest: Manifest
    ) async throws -> [Path: ItemStatus] {
        let peripheralManifest = try await peripheralArchive.getManifest()
        return peripheralManifest.changesSince(manifest)
    }

    func planSync(
        mobileChanges: [Path: ItemStatus],
        peripheralChanges: [Path: ItemStatus]
    ) -> [Path: Action] {
        var result: [Path: Action] = [:]

        let paths = Set(mobileChanges.keys).union(peripheralChanges.keys)

        for path in paths {
            let mobileItemState = mobileChanges[path]
            let peripheralItemState = peripheralChanges[path]

            // ignore identical changes
            guard mobileItemState != peripheralItemState else {
                continue
            }

            switch (mobileItemState, peripheralItemState) {
            // changes on mobile
            case let (.some(change), .none):
                switch change {
                case .modified: result[path] = .update(.peripheral)
                case .deleted: result[path] = .delete(.peripheral)
                }
            // changes on peripheral
            case let (.none, .some(change)):
                switch change {
                case .modified: result[path] = .update(.mobile)
                case .deleted: result[path] = .delete(.mobile)
                }
            // changes on both devices
            case let (.some(mobileChange), .some(peripheralChange)):
                switch (mobileChange, peripheralChange) {
                // modifications override deletions
                case (.deleted, .modified): result[path] = .update(.mobile)
                case (.modified, .deleted): result[path] = .update(.peripheral)
                // possible conflicts
                case (.modified, .modified): result[path] = .conflict
                default: fatalError("unreachable")
                }
            default:
                fatalError("unreachable")
            }
        }

        return result
    }

    func reset() {
        manifestStorage.manifest = nil
    }
}

// MARK: Manifest changes

extension Manifest {
    func changesSince(
        _ manifest: Manifest
    ) -> [Path: Synchronization.ItemStatus] {
        var result: [Path: Synchronization.ItemStatus] = [:]

        let paths = Set(self.items.map { $0.path })
            .union(manifest.items.map { $0.path })

        for path in paths {
            let newItem = self[path]
            let savedItem = manifest[path]

            // skip not modified
            guard newItem != savedItem else {
                continue
            }

            switch (newItem, savedItem) {
            case (nil, .some):
                result[path] = .deleted
            case let (.some(item), nil):
                result[path] = .modified(item.hash)
            case let (.some(item), .some):
                result[path] = .modified(item.hash)
            default:
                fatalError("unreachable")
            }
        }

        return result
    }
}

// MARK: CustomStringConvertible

extension Synchronization.Action: CustomStringConvertible {
    public var description: String {
        switch self {
        case .update(let target): return "update: \(target)"
        case .delete(let target): return "delete \(target)"
        case .conflict: return "confilct"
        }
    }
}

extension Synchronization.Action.Target: CustomStringConvertible {
    public var description: String {
        switch self {
        case .mobile: return "mobile"
        case .peripheral: return "peripheral"
        }
    }
}

extension Synchronization.ItemStatus: CustomStringConvertible {
    public var description: String {
        switch self {
        case .deleted: return "deleted"
        case .modified(let hash): return "modified: \(hash.value)"
        }
    }
}
