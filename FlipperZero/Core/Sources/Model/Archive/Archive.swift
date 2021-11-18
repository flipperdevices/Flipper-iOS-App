import Combine
import Injector
import Foundation

public class Archive: ObservableObject {
    public static let shared: Archive = .init()

    @Inject var storage: ArchiveStorage

    var start: Date = .init()
    @Published public var isSynchronizing = false {
        didSet {
            switch isSynchronizing {
            case true: start = .init()
            case false: print(Date().timeIntervalSince(start))
            }
        }
    }

    @Published public var items: [ArchiveItem] = [] {
        didSet {
            storage.items = items
        }
    }

    private let flipperArchive: FlipperArchive = .shared

    private init() {
        items = storage.items
    }

    public func append(_ item: ArchiveItem) {
        items.removeAll { $0.id == item.id }
        items.append(item)
    }

    public func delete(_ item: ArchiveItem) {
        updateStatus(of: item, to: .deleted)
    }

    public func favorite(_ item: ArchiveItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].isFavorite.toggle()
        }
    }

    public func updateStatus(
        of item: ArchiveItem,
        to status: ArchiveItem.Status
    ) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].status = status
        }
    }

    public func importKey(_ item: ArchiveItem) {
        append(item)
    }

    public func importKey(name: String, data: [UInt8]) {
        let content = String(decoding: data, as: UTF8.self)
        guard let item = ArchiveItem(
            fileName: name,
            content: content,
            status: .imported
        ) else {
            print("importKey error, invalid data")
            return
        }
        importKey(item)
    }

    public func syncWithDevice(completion: @escaping () -> Void = {}) {
        guard !isSynchronizing else { return }
        isSynchronizing = true

        syncImportedItems { [weak self] in
            self?.syncDeletedItems { [weak self] in
                self?.syncDeviceItems {
                    self?.isSynchronizing = false
                    completion()
                }
            }
        }
    }

    private func syncImportedItems(completion: @escaping () -> Void) {
        let imported = items.filter {
            $0.status == .imported || $0.status == .synchronizing
        }

        guard !imported.isEmpty else {
            completion()
            return
        }

        for item in imported {
            updateStatus(of: item, to: .synchronizing)

            let path = Path(components: ["any", item.fileType.directory, item.fileName])
            flipperArchive.writeKey(item.content, at: path) { [weak self] result in
                switch result {
                case .success:
                    self?.updateStatus(of: item, to: .synchronizied)
                case .failure(let error):
                    self?.updateStatus(of: item, to: .error)
                    print(error)
                }

                if item == imported.last {
                    completion()
                }
            }
        }
    }

    private func syncDeletedItems(completion: @escaping () -> Void) {
        // delete marked as deleted
        let deleted = items.filter { $0.status == .deleted }
        guard !deleted.isEmpty else {
            completion()
            return
        }
        for item in deleted {
            flipperArchive.delete(item) { [weak self] result in
                switch result {
                case .success:
                    self?.items.removeAll { $0.id == item.id }
                    print("deleted")
                case .failure(let error):
                    print(error)
                }
            }
            if item == deleted.last {
                completion()
            }
        }
    }

    private func syncDeviceItems(completion: @escaping () -> Void) {
        flipperArchive.listAllFiles { [weak self] result in
            switch result {
            case .success(let paths):
                self?.syncFiles(paths, completion: completion)
            case .failure(let error):
                print(error)
                completion()
            }
        }
    }

    private func syncFiles(_ paths: [Path], completion: @escaping () -> Void) {
        removeDeletedOnDevice(paths)
        guard !paths.isEmpty else {
            completion()
            return
        }
        for path in paths {
            guard let newItem = ArchiveItem(
                with: path,
                content: "",
                status: .synchronizing)
            else {
                print("invalid path")
                continue
            }
            // skip existing
            guard !items.contains( where: { $0.id == newItem.id }) else {
                if path == paths.last {
                    completion()
                }
                continue
            }
            append(newItem)
            flipperArchive.readFile(at: path) { [weak self] result in
                switch result {
                case .success(let content):
                    self?.updateItem(id: newItem.id, with: content)
                case .failure(let error):
                    print(error)
                }
                if path == paths.last {
                    completion()
                }
            }
        }
    }

    private func removeDeletedOnDevice(_ paths: [Path]) {
        let ids = paths.map { $0.components.last }
        self.items.removeAll {
            $0.status == .synchronizied && !ids.contains($0.id)
        }
    }

    private func updateItem(id: ArchiveItem.ID, with content: String) {
        if let index = items.firstIndex(where: { $0.id == id }) {
            guard let properties = [ArchiveItem.Property](text: content) else {
                items[index].status = .error
                return
            }
            var item = items[index]
            item.properties = properties
            item.status = .synchronizied
            items[index] = item
        }
    }
}

extension ArchiveItem {
    init?(with path: Path, content: String, status: Status) {
        guard let fileName = path.components.last else {
            return nil
        }
        self.init(fileName: fileName, content: content, status: status)
    }
}
extension ArchiveItem {
    var path: Path {
        .init(components: ["any", fileType.directory, fileName])
    }
}
