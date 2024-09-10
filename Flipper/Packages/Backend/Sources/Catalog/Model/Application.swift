import Macro
import Foundation

public struct Application: Equatable, Identifiable, Decodable {
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

    public enum Status: String, Decodable {
        case ready = "READY"
        case building = "BUILD_RUNNING"
        case unsupported = "UNSUPPORTED_APPLICATION"
        case unsupportedSDK = "UNSUPPORTED_SDK"
        case outdatedDevice = "FLIPPER_OUTDATED"
    }

    public struct Current: Equatable, Decodable {
        public let id: String
        public let name: String
        public let version: String
        public let shortDescription: String
        public let icon: ImageSource
        public let screenshots: [URL]
        public let status: Status
        public let build: Build?
        // Full
        public let description: String?
        public let changelog: String?
        public let links: Links?

        public init(
            id: String,
            name: String,
            version: String,
            shortDescription: String,
            icon: ImageSource,
            screenshots: [URL],
            status: Status,
            build: Build?,
            description: String?,
            changelog: String?,
            links: Links?
        ) {
            self.id = id
            self.name = name
            self.version = version
            self.shortDescription = shortDescription
            self.icon = icon
            self.screenshots = screenshots
            self.status = status
            self.build = build
            self.description = description
            self.changelog = changelog
            self.links = links
        }

        enum CodingKeys: String, CodingKey {
            case id = "_id"
            case name
            case version
            case shortDescription = "short_description"
            case icon = "icon_uri"
            case screenshots
            case status
            case build = "current_build"
            // Full
            case description
            case changelog
            case links
        }
    }

    public struct Build: Equatable, Decodable {
        public let id: String
        public let sdk: SDK
        public let asset: Asset?

        enum CodingKeys: String, CodingKey {
            case id = "_id"
            case sdk
            case asset = "metadata"
        }

        public struct SDK: Equatable, Decodable {
            public let id: String
            public let name: String
            public let target: String
            public let api: String
            public let isLatestRelease: Bool

            enum CodingKeys: String, CodingKey {
                case id = "_id"
                case name
                case target
                case api
                case isLatestRelease = "is_latest_release"
            }
        }

        public struct Asset: Equatable, Decodable {
            public let id: String
            public let filename: String
            public let length: Int

            enum CodingKeys: String, CodingKey {
                case id = "_id"
                case filename
                case length
            }
        }
    }

    public struct Links: Equatable, Decodable {
        public let bundle: URL
        public let manifest: URL
        public let source: Source

        enum CodingKeys: String, CodingKey {
            case bundle = "bundle_uri"
            case manifest = "manifest_uri"
            case source = "source_code"
        }

        public struct Source: Equatable, Decodable {
            public let type: String
            public let uri: URL
        }
    }
}

public extension Optional where Wrapped == Application.Links {
    var github: URL {
        self?.source.uri ?? #URL("http://github.com")
    }

    var manifest: URL {
        self?.manifest ?? #URL("http://github.com")
    }
}
