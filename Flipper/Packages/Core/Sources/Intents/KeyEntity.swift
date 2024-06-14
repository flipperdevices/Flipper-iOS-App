import AppIntents

struct KeyEntity: AppEntity, Identifiable {
    var id: String

    // Visual representation e.g. in the dropdown, when selecting the entity.
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(id)")
    }

    // Placeholder whenever it needs to present your entity’s type onscreen.
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Key"

    static var defaultQuery = KeyQuery()
}

struct KeyQuery: EntityQuery {
    func suggestedEntities() async throws -> [KeyEntity] {
        [
            .init(id: "Open Huiopen"),
            .init(id: "Close Huiose")
        ]
    }

    // Find Entity by id to bridge the Shortcuts Entity to your App
    func entities(for identifiers: [String]) async throws -> [KeyEntity] {
        [
            .init(id: "Open Huiopen"),
            .init(id: "Close Huiose")
        ].filter { identifiers.contains($0.id) }
    }
}
