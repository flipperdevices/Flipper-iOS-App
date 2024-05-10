import Peripheral

class FlipperFavorites: FavoritesStorage {
    let filename = "favorites.txt"
    var path: Path { .init(components: ["any", filename]) }

    private var storage: StorageAPI

    init(storage: StorageAPI) {
        self.storage = storage
    }

    func read() async throws -> Favorites {
        do {
            let bytes = try await storage.read(at: path).drain()
            let content = String(decoding: bytes, as: UTF8.self)
            return try .init(decoding: content)
        } catch let error as Peripheral.Error {
            if error == .storage(.doesNotExist) {
                return .init([])
            } else {
                throw error
            }
        }
    }

    func write(_ favorites: Favorites) async throws {
        let content = try favorites.encode()
        let bytes = [UInt8](content.utf8)
        try await storage.write(at: path, bytes: bytes).drain()
    }
}
