import Inject
import Logging
import Combine
import Foundation

public class Archive: ObservableObject {
    public static let shared: Archive = .init()
    private let logger = Logger(label: "archive")

    @Inject var mobileArchive: MobileArchiveProtocol
    @Inject var synchronization: SynchronizationProtocol

    @Published public var items: [ArchiveItem] = []
    @Published public var deletedItems: [ArchiveItem] = []

    @Published public var isSyncronizing = false

    private var disposeBag: DisposeBag = .init()

    private init() {
        synchronization.events
            .sink { [weak self] in
                self?.onSyncEvent($0)
            }
            .store(in: &disposeBag)

        load()
    }

    func load() {
        isSyncronizing = true
        Task {
            var items = [ArchiveItem]()
            for next in try await mobileArchive.manifest.items {
                guard let item = try await mobileArchive.read(next.id) else {
                    logger.error("invalid item \(next.id)")
                    continue
                }
                items.append(item)
            }
            self.items = items
            isSyncronizing = false
        }
    }

    func onSyncEvent(_ event: Synchronization.Event) {
        Task {
            switch event {
            case .imported(let id):
                if var item = try await mobileArchive.read(id) {
                    item.status = .synchronizied
                    items.append(item)
                }
            case .exported(let id):
                if let index = items.firstIndex(where: { $0.id == id }) {
                    items[index].status = .synchronizied
                }
            case .deleted(let id):
                items.removeAll { $0.id == id }
            }
        }
    }
}

extension Archive {
    public func get(_ id: ArchiveItem.ID) -> ArchiveItem? {
        items.first { $0.id == id }
    }

    public func upsert(_ item: ArchiveItem) async throws {
        try await mobileArchive.upsert(item)
        items.removeAll { $0.id == item.id }
        items.append(item)
    }

    public func delete(_ id: ArchiveItem.ID) async throws {
        if let item = get(id) {
            try await mobileArchive.delete(id)
            deletedItems.append(item)
        }
    }
}

extension Archive {
    public func wipe(_ id: ArchiveItem.ID) async throws {
        try await deletedArchive.delete(id)
        deletedItems.removeAll { $0.id == id }
    }

    public func rename(_ id: ArchiveItem.ID, to name: String) {
        if let item = get(id) {
            let newItem = item.rename(to: .init(name))
            items.removeAll { $0.id == item.id }
            items.append(newItem)
        }
    }

    public func restore(_ item: ArchiveItem) async throws {
        let manifest = try await mobileArchive.manifest
        // TODO: resolve conflicts
        guard manifest[item.id] == nil else {
            logger.error("alredy exists")
            return
        }
        try await mobileArchive.upsert(item)
        items.append(item)
        deletedItems.removeAll { $0.id == item.id }
    }

    public func favorite(_ id: ArchiveItem.ID) {
        if let index = items.firstIndex(where: { $0.id == id }) {
            objectWillChange.send()
            items[index].isFavorite.toggle()
        }
    }
}

extension Archive {
    public func importKey(_ item: ArchiveItem) async throws {
        let isExist = items
            .filter { $0.status != .deleted }
            .contains { item.id == $0.id && item.content == $0.content }

        if !isExist {
            var item = item
            item.status = .imported
            try await upsert(item)
        }
    }
}

extension Archive {
    public func syncWithDevice() async {
        guard !isSyncronizing else { return }
        do {
            try await synchronization.syncWithDevice()
        } catch {
            logger.critical("syncronization error: \(error)")
        }
    }
}
