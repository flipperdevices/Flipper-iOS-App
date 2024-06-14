import AppIntents

struct KeyQuery: EntityQuery {
    func suggestedEntities() async throws -> [KeyEntity] {
        guard
            let value = UserDefaults.group.value(forKey: "synced_manifest"),
            let values = value as? [String]
        else {
            return []
        }
        return values.compactMap { value in
            .init(path: value)
        }
    }

    // Find Entity by id to bridge the Shortcuts Entity to your App
    func entities(for identifiers: [String]) async throws -> [KeyEntity] {
        try await suggestedEntities().filter {
            identifiers.contains($0.id)
        }
    }
}
