import Peripheral

extension Favorites: PlaintextCodable {
    init(decoding content: String) throws {
        var favorites: Favorites = .init()
        for var line in content.split(separator: "\n") {
            if line.starts(with: "/any/") {
                line = "/ext" + line.dropFirst(4)
            }
            favorites.upsert(.init(string: line))
        }
        self = favorites
    }

    func encode() throws -> String {
        var result: String = ""
        for path in paths {
            result.append("\(path)\n")
        }
        return result
    }
}
