extension ArchiveItem {
    init?(fileName: String, content: String) {
        guard let name = Name(fileName: fileName) else {
            print("invalid file name: \(fileName)")
            return nil
        }

        guard let type = FileType(fileName: fileName) else {
            print("invalid file type: \(fileName)")
            return nil
        }

        guard let properties = [Property](text: content) else {
            print("invalid content: \(content)")
            return nil
        }

        self = .init(
            id: fileName,
            name: name,
            fileType: type,
            properties: properties,
            isFavorite: false)
    }

    public var fileName: String {
        "\(name).\(fileType.extension)"
    }

    public var content: String {
        properties.reduce(into: "") { result, property in
            for line in property.description {
                result += "# \(line)\n"
            }
            result += "\(property.key): \(property.value)\n"
        }
    }
}

extension ArchiveItem.Name {
    init?<T: StringProtocol>(fileName: T) {
        guard let name = fileName.split(separator: ".").first else {
            return nil
        }
        self.value = String(name)
    }
}

extension ArchiveItem.FileType {
    init?<T: StringProtocol>(fileName: T) {
        guard let `extension` = fileName.split(separator: ".").last else {
            return nil
        }
        switch `extension` {
        case "ibtn": self = .ibutton
        case "nfc": self = .nfc
        case "sub": self = .subghz
        case "rfid": self = .rfid
        case "ir": self = .irda
        default: return nil
        }
    }

    public var `extension`: String {
        switch self {
        case .ibutton: return "ibtn"
        case .nfc: return "nfc"
        case .subghz: return "sub"
        case .rfid: return "rfid"
        case .irda: return "ir"
        }
    }

    var directory: String {
        switch self {
        case .ibutton: return "ibutton"
        case .nfc: return "nfc"
        case .subghz: return "subghz/saved"
        case .rfid: return "lfrfid"
        case .irda: return "irda"
        }
    }
}

extension Array where Element == ArchiveItem.Property {
    init?(text: String) {
        var comments: [String] = []
        var properties: [ArchiveItem.Property] = []

        for line in text.split(separator: "\n") {
            guard !line.starts(with: "#") else {
                let comment = line.dropFirst()
                comments.append(comment.trimmingCharacters(in: .whitespaces))
                continue
            }
            let description = comments
            comments.removeAll()

            let parts = line.split(separator: ":", maxSplits: 1)
            guard parts.count == 2 else {
                return nil
            }
            guard let key = parts.first, let value = parts.last else {
                return nil
            }
            properties.append(.init(
                key: String(key.trimmingCharacters(in: .whitespaces)),
                value: String(value.trimmingCharacters(in: .whitespaces)),
                description: description))
        }

        self = properties
    }
}
