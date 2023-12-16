public protocol LoggerStorage {
    func list() async -> [String]
    func read(_ name: String) async -> [String]

    func write(_ message: String) async
    func delete(_ name: String) async
}
