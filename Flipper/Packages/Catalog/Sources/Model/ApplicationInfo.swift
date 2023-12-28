import Foundation

public struct ApplicationInfo: Equatable, Decodable {
    public let id: String
    public let alias: String
    public let categoryId: String
    public let created: TimeStamp
    public let updated: TimeStamp
    public let current: Current

    public init(
        id: String,
        alias: String,
        categoryId: String,
        created: TimeStamp,
        updated: TimeStamp,
        current: Current
    ) {
        self.id = id
        self.alias = alias
        self.categoryId = categoryId
        self.created = created
        self.updated = updated
        self.current = current
    }

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case alias
        case created = "created_at"
        case updated = "updated_at"
        case categoryId = "category_id"
        case current = "current_version"
    }

    public struct Current: Equatable, Decodable {
        public let id: String
        public let name: String
        public let version: String
        public let shortDescription: String
        public let icon: ImageSource
        public let screenshots: [URL]
        public let status: Application.Status

        public init(
            id: String,
            name: String,
            version: String,
            shortDescription: String,
            icon: ImageSource,
            screenshots: [URL],
            status: Application.Status
        ) {
            self.id = id
            self.name = name
            self.version = version
            self.shortDescription = shortDescription
            self.icon = icon
            self.screenshots = screenshots
            self.status = status
        }

        enum CodingKeys: String, CodingKey {
            case id = "_id"
            case name
            case version
            case shortDescription = "short_description"
            case icon = "icon_uri"
            case screenshots
            case status
        }
    }
}

extension ApplicationInfo {
    public init(_ application: Application) {
        self.id = application.id
        self.alias = application.alias
        self.categoryId = application.categoryId
        self.created = application.created
        self.updated = application.updated
        self.current = .init(application.current)
    }
}

extension ApplicationInfo.Current {
    public init(_ current: Application.Current) {
        self.id = current.id
        self.name = current.name
        self.version = current.version
        self.shortDescription = current.shortDescription
        self.icon = current.icon
        self.screenshots = current.screenshots
        self.status = current.status
    }
}
