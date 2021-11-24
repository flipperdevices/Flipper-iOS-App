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

    public func replace(_ item: ArchiveItem) {
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
        replace(item)
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

    public func syncWithDevice() async {
        guard !isSynchronizing else { return }

        isSynchronizing = true

        await syncImportedItems()
        await syncDeletedItems()
        await syncDeviceItems()

        isSynchronizing = false
    }

    private func syncImportedItems() async {
        let imported = items.filter {
            $0.status == .imported ||
            // TODO: compare hash
            $0.status == .modified ||
            $0.status == .synchronizing
        }

        for item in imported {
            updateStatus(of: item, to: .synchronizing)

            let path = Path(components: ["ext", item.fileType.directory, item.fileName])
            do {
                try await flipperArchive.writeKey(item.content, at: path)
                updateStatus(of: item, to: .synchronizied)
            } catch {
                updateStatus(of: item, to: .error)
                print(error)
            }
        }
    }

    private func syncDeletedItems() async {
        // delete marked as deleted
        let deleted = items.filter { $0.status == .deleted }
        for item in deleted {
            do {
                try await flipperArchive.delete(item)
                items.removeAll { $0.id == item.id }
                print("deleted")
            } catch {
                print(error)
            }
        }
    }

    private func syncDeviceItems() async {
        do {
            let paths = try await flipperArchive.listAllFiles()
            try await syncFiles(paths)
        } catch {
            print(error)
        }
    }

    private func syncFiles(_ paths: [Path]) async throws {
        removeDeletedOnDevice(paths)

        for path in paths {
            let id = ArchiveItem.ID(path)

            // TODO: skip imported/exported files
            if let current = items.first(where: { $0.id == id }) {
                let hash = try await flipperArchive.getFileHash(at: path)
                // skip reading if not modified
                guard current.hash != hash else {
                    continue
                }
                print("updating current from:", path)
                print(current.hash, hash)
            }

            guard let tempItem = ArchiveItem(
                at: path,
                content: "",
                status: .synchronizing
            ) else {
                print("can't create new item")
                continue
            }

            replace(tempItem)
            let content = try await flipperArchive.readFile(at: path)
            updateItem(id: id, with: content)
        }
    }

    private func removeDeletedOnDevice(_ paths: [Path]) {
        let ids = paths.map { ArchiveItem.ID($0) }
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
    init?(at path: Path, content: String, status: Status) {
        guard let fileName = path.components.last else {
            return nil
        }
        self.init(fileName: fileName, content: content, status: status)
    }
}

extension ArchiveItem {
    var path: Path {
        .init(components: ["ext", fileType.directory, fileName])
    }
}

extension ArchiveItem {
    var hash: String {
        return content.md5
    }
}

import CryptoKit

extension String {
    var md5: String {
        Insecure.MD5.hash(data: data(using: .utf8) ?? Data()).map {
            String(format: "%02hhx", $0)
        }.joined()
    }
}
