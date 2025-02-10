import Foundation

struct FileManagerSettings: Codable, RawRepresentable {
    var isHiddenFilesShow: Bool = false
    var displayType: DisplayType = .list

    enum DisplayType: String, Codable {
        case list
        case grid
    }

    enum CodingKeys: String, CodingKey {
        case isHiddenFilesShow
        case displayType
    }

    init() {}

    var rawValue: String {
        guard let data = try? JSONEncoder().encode(self) else { return "" }
        return String(decoding: data, as: UTF8.self)
    }

    init?(rawValue: String) {
        guard
            let value = try? JSONDecoder().decode(
                Self.self,
                from: .init(rawValue.utf8)
            )
        else {
            return nil
        }
        self = value
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        isHiddenFilesShow = try container.decode(
            Bool.self,
            forKey: .isHiddenFilesShow)
        displayType = try container.decode(
            DisplayType.self,
            forKey: .displayType)
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(isHiddenFilesShow, forKey: .isHiddenFilesShow)
        try container.encode(displayType, forKey: .displayType)
    }
}

struct FileManagerNewElement {
    var name: String
    let isNewDirectory: Bool

    init(name: String, isNewDirectory: Bool) {
        self.name = name
        self.isNewDirectory = isNewDirectory
    }

    var namePlaceholder: String {
        "\(isNewDirectory ? "directory" : "file") name"
    }
}
