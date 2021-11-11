import Combine
import Injector

public class Archive: ObservableObject {
    public static let shared: Archive = .init()

    @Inject var storage: ArchiveStorage

    @Published public var isSynchronizing = false
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

    public func importKey(
        name: String,
        data: [UInt8],
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let content = String(decoding: data, as: UTF8.self)
        guard let item = ArchiveItem(fileName: name, content: content) else {
            print("importKey error, invalid data")
            return
        }
        append(item)
        let path = Path(components: ["any", item.fileType.directory, name])
        flipperArchive.writeKey(data, at: path) { result in
            completion(result)
        }
    }

    public func syncWithDevice(completion: @escaping () -> Void) {
        isSynchronizing = true
        flipperArchive.readAllItems { [weak self] result in
            self?.isSynchronizing = false
            switch result {
            case .success(let items): self?.items = items
            case .failure(let error): print(error)
            }
            completion()
        }
    }
}
