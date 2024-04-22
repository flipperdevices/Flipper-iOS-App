public protocol ManifestStorage {
    func get() async throws -> Manifest
    func upsert(_ manifest: Manifest) async throws
    func delete() async throws
}
