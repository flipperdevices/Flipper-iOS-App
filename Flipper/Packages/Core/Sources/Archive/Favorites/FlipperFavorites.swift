import Peripheral

class FlipperFavorites: FlipperFavoritesProtocol {
    let filename = "favorites.txt"
    var path: Path { .init(components: ["any", filename]) }

    private var pairedDevice: PairedDevice
    private var rpc: RPC { pairedDevice.session }

    init(pairedDevice: PairedDevice) {
        self.pairedDevice = pairedDevice
    }

    func read() async throws -> Favorites {
        do {
            let bytes = try await rpc.readFile(at: path)
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
        try await rpc.writeFile(at: path, bytes: bytes)
    }
}
