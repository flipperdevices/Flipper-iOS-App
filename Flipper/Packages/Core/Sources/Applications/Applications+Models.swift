import Catalog

import Foundation

extension Applications {
    public struct Category: Identifiable {
        public let id: String
        public let icon: URL
        public let name: String
        public let applications: Int
    }

    public struct Application: Identifiable {
        public let id: String
        public let name: String
        public let alias: String
        public let icon: URL
        public let description: String
        public var screenshots: [URL]
        public var category: Category
        public var status: Status
        public let version: String
        public let size: String
        public let api: String
        public let changelog: String
        public let created: Date
        public let updated: Date

        public enum Status {
            case installing(progress: Double)
            case updating(progress: Double)
            case notInstalled
            case installed
            case outdated
        }
    }
}

extension Applications.Category {
    static var uncategorized: Applications.Category {
        .init(
            id: UUID().uuidString,
            icon: "https://catalog.flipp.dev/api/v0/category/646a6c8965f689c82d711048/icon",
            name: "Uncategorized",
            applications: 0
        )
    }

    init(_ source: Catalog.Category) {
        self.id = source.id
        self.icon = source.icon
        self.name = source.name
        self.applications = 0
    }
}

extension Applications.Application {
    init(_ source: Catalog.Application) {
        self.id = source.id
        self.name = source.name
        self.alias = source.alias
        self.icon = source.current.icon
        self.description = source.current.description
        self.screenshots = source.current.screenshots

        self.category = .uncategorized
        self.status = .notInstalled

        self.version = source.current.version
        self.size = "100 KB"
        self.api = "2.2"
        self.changelog = ""

        self.created = .init(timeIntervalSince1970: .init(source.created))
        self.updated = .init(timeIntervalSince1970: .init(source.updated))
    }
}
