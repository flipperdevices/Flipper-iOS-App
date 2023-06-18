import Foundation

public struct Application: Decodable {
    public let id: String
    public let alias: String
    public let categoryId: String
    public let created: TimeStamp
    public let updated: TimeStamp
    public let current: Current

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case alias
        case created = "created_at"
        case updated = "updated_at"
        case categoryId = "category_id"
        case current = "current_version"
    }

    public struct Current: Decodable {
        public let id: String
        public let name: String
        public let version: String
        public let shortDescription: String
        public let icon: URL
        public let screenshots: [URL]
        // Full
        public let description: String?
        public let changelog: String?
        public let build: Build?
        public let bundle: Bundle?
        public let links: Links?

        enum CodingKeys: String, CodingKey {
            case id = "_id"
            case name
            case version
            case shortDescription = "short_description"
            case icon = "icon_uri"
            case screenshots
            // Full
            case description
            case changelog
            case build = "current_build"
            case bundle
            case links
        }
    }

    public struct Build: Decodable {
        public let id: String
        public let gfsID: String
        public let sdk: SDK

        enum CodingKeys: String, CodingKey {
            case id = "_id"
            case gfsID = "build_gfs_id"
            case sdk
        }

        public struct SDK: Decodable {
            public let id: String
            public let name: String
            public let target: String
            public let api: String

            enum CodingKeys: String, CodingKey {
                case id = "_id"
                case name
                case target
                case api
            }
        }
    }

    public struct Bundle: Decodable {
        public let id: String
        public let filename: String
        public let length: Int

        enum CodingKeys: String, CodingKey {
            case id = "_id"
            case filename
            case length
        }
    }

    public struct Links: Decodable {
        public let bundle: URL
        public let manifest: URL
        public let source: Source

        enum CodingKeys: String, CodingKey {
            case bundle = "bundle_uri"
            case manifest = "manifest_uri"
            case source = "source_code"
        }

        public struct Source: Decodable {
            public let type: String
            public let uri: URL
        }
    }
}
