extension ArchiveItem {
    public struct Property: Equatable, Hashable {
        public let key: String
        public var value: String
        public var description: [String] = []

        public init(key: String, value: String, description: [String] = []) {
            self.key = key
            self.value = value
            self.description = description
        }
    }
}

extension ArchiveItem {
    public var content: String {
        properties.content
    }

    public var shadowContent: String {
        shadowCopy.content
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

        let lines = content.split { $0 == "\n" || $0 == "\r\n" }

        for line in lines {
            guard !line.starts(with: "#") else {
                let comment = line.dropFirst()
                comments.append(comment.trimmingCharacters(in: .whitespaces))
                continue
            }
            let description = comments
            comments.removeAll()

            guard line.contains(":") else { return nil }

            let keyValue = line.split(separator: ":", maxSplits: 1)
            let key = keyValue[0]
            let value = keyValue.count == 2 ? keyValue[1] : ""

            properties.append(.init(
                key: String(key.trimmingCharacters(in: .whitespaces)),
                value: String(value.trimmingCharacters(in: .whitespaces)),
                description: description))
        }

        self = properties
    }
}
