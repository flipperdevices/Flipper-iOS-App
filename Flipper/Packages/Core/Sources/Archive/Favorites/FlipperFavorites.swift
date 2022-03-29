import Peripheral

class FlipperFavorites: FlipperFavoritesProtocol {
    let rpc: RPC = .shared
    let filename = "favorites.txt"
    var path: Path { .init(components: ["ext", filename]) }

    func read() async throws -> Favorites {
        let bytes = try await rpc.readFile(at: path, priority: .background)
        let content = String(decoding: bytes, as: UTF8.self)
        return try .init(decoding: content)
    }

    func write(_ favorites: Favorites) async throws {
        let content = try favorites.encode()
        let bytes = [UInt8](content.utf8)
        try await rpc.writeFile(at: path, bytes: bytes)
    }
}
