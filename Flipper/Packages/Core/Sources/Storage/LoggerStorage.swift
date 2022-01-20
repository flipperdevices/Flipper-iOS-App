public protocol LoggerStorage {
    func list() -> [String]
    func read(_ name: String) -> [String]

    func write(_ message: String)
    func delete(_ name: String)
}
