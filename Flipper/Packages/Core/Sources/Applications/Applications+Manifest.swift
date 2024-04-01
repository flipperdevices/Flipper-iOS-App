import Foundation

extension Applications {
    public struct Manifest: Codable {
        private static var fileType: String {
            "Flipper Application Installation Manifest"
        }

        private static var version: Int {
            1
        }

        public let fileType: String = Manifest.fileType
        public let version: Int = Manifest.version
        public let fullName: String
        public let icon: Data
        public let buildAPI: String
        public let uid: String
        public let versionUID: String
        public let path: String
        public let isDevCatalog: Bool

        init(
            fullName: String,
            icon: Data,
            buildAPI: String,
            uid: String,
            versionUID: String,
            path: String,
            isDevCatalog: Bool
        ) {
            self.fullName = fullName
            self.icon = icon
            self.buildAPI = buildAPI
            self.uid = uid
            self.versionUID = versionUID
            self.path = path
            self.isDevCatalog = isDevCatalog
        }

        enum CodingKeys: String, CodingKey {
            case fileType = "Filetype"
            case version = "Version"
            case fullName = "Full Name"
            case icon = "Icon"
            case buildAPI = "Version Build API"
            case uid = "UID"
            case versionUID = "Version UID"
            case path = "Path"
            case isDevCatalog = "DevCatalog"
        }

        public init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<CodingKeys> = try decoder
                .container(keyedBy: CodingKeys.self)
            self.fullName = try container.decode(String.self, forKey: .fullName)
            let base64Icon = try container.decode(String.self, forKey: .icon)
            self.icon = Data(base64Encoded: base64Icon) ?? .init()
            self.buildAPI = try container.decode(String.self, forKey: .buildAPI)
            self.uid = try container.decode(String.self, forKey: .uid)
            self.versionUID = try container
                .decode(String.self, forKey: .versionUID)
            self.path = try container.decode(String.self, forKey: .path)
            self.isDevCatalog = container.contains(.isDevCatalog)
                ? try container.decode(Bool.self, forKey: .isDevCatalog)
                : false
        }

        public func encode(to encoder: Encoder) throws {
            var container: KeyedEncodingContainer<CodingKeys> = encoder
                .container(keyedBy: CodingKeys.self)
            try container.encode(fileType, forKey: .fileType)
            try container.encode(version, forKey: .version)
            try container.encode(fullName, forKey: .fullName)
            try container.encode(icon.base64EncodedString(), forKey: .icon)
            try container.encode(buildAPI, forKey: .buildAPI)
            try container.encode(uid, forKey: .uid)
            try container.encode(versionUID, forKey: .versionUID)
            try container.encode(path, forKey: .path)
            if isDevCatalog == true {
                try container.encode(true, forKey: .isDevCatalog)
            }
        }
    }
}

import Catalog

extension Application {
    init?(_ manifest: Applications.Manifest) {
        guard let filename = manifest.path.split(separator: "/").last else {
            return nil
        }
        let alias = filename
            .split(separator: ".", omittingEmptySubsequences: false)
            .dropLast()
            .joined(separator: ".")

        let application = Catalog.Application(
            id: manifest.uid,
            alias: alias,
            categoryId: "",
            created: .init(),
            updated: .init(),
            current: .init(
                id: manifest.versionUID,
                name: manifest.fullName,
                version: "",
                shortDescription: "",
                icon: .data(manifest.icon),
                screenshots: [],
                status: .ready,
                build: nil,
                description: nil,
                changelog: nil,
                links: nil
            )
        )

        guard let category = Category(path: manifest.path) else {
            return nil
        }

        self.init(application: application, category: category)
    }
}

private extension Application.Category {
    init?(path: String) {
        let parts = path.split(separator: "/")
        guard parts.count == 4 else {
            return nil
        }
        self.init(name: String(parts[2]))
    }
}
