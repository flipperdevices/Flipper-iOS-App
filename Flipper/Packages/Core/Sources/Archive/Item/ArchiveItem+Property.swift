extension ArchiveItem {
    public struct Property: Codable, Equatable {
        public let key: String
        public var value: String
        public var description: [String] = []
    }
}

extension ArchiveItem {
    public var content: String {
        properties.content
    }
}

extension Array where Element == ArchiveItem.Property {
    public var content: String {
        reduce(into: "") { result, property in
            for line in property.description {
                result += "# \(line)\n"
            }
            result += "\(property.key): \(property.value)\n"
        }
    }

    init?(content: String) {
        var comments: [String] = []
        var properties: [ArchiveItem.Property] = []

        for line in content.split(separator: "\n") {
            guard !line.starts(with: "#") else {
                let comment = line.dropFirst()
                comments.append(comment.trimmingCharacters(in: .whitespaces))
                continue
            }
            let description = comments
            comments.removeAll()

            let keyValue = line.split(separator: ":", maxSplits: 1)
            guard keyValue.count == 2 else { return nil }
            properties.append(.init(
                key: String(keyValue[0].trimmingCharacters(in: .whitespaces)),
                value: String(keyValue[1].trimmingCharacters(in: .whitespaces)),
                description: description))
        }

        self = properties
    }
}
