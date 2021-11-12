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
        items.removeAll { $0.id == item.id }
        flipperArchive.delete(item) { result in
            switch result {
            case .success:
                print("deleted")
            case .failure(let error):
                print(error)
            }
        }
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

    public func importKey(
        _ item: ArchiveItem,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        append(item)
        let path = Path(components: ["any", item.fileType.directory, item.fileName])
        isSynchronizing = true
        updateStatus(of: item, to: .synchronizing)
        flipperArchive.writeKey(item.content, at: path) { [weak self] result in
            self?.isSynchronizing = false
            self?.updateStatus(of: item, to: .synchronizied)
            completion(result)
        }
    }

    public func importKey(
        name: String,
        data: [UInt8],
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let content = String(decoding: data, as: UTF8.self)
        guard let item = ArchiveItem(
            fileName: name,
            content: content,
            status: .imported
        ) else {
            print("importKey error, invalid data")
            return
        }
        importKey(item, completion: completion)
    }

    public func syncWithDevice(completion: @escaping () -> Void) {
        isSynchronizing = true
        flipperArchive.listAllFiles { [weak self] result in
            self?.isSynchronizing = false
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
        isSynchronizing = true
        removeMissing(paths)
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
                    isSynchronizing = false
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
                    self?.isSynchronizing = false
                    completion()
                }
            }
        }
    }

    private func removeMissing(_ paths: [Path]) {
        let ids = paths.map { $0.components.last }
        self.items.removeAll { !ids.contains($0.id) }
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
