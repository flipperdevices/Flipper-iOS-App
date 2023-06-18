import Catalog

import Foundation

extension Applications {
    public struct Category: Identifiable {
        public let id: String
        public let icon: ImageSource
        public let name: String
        public let applications: Int

        public enum ImageSource {
            case assets(String)
            case remote(URL)
        }
    }

    public struct Application: Identifiable {
        public let id: String
        public let name: String
        public let alias: String
        public let icon: URL
        public let description: String?
        public let shortDescription: String
        public var screenshots: [URL]
        public var category: Category
        public var status: Status
        public let version: String?
        public let size: String?
        public let api: String?
        public let changelog: String?
        public let created: Date
        public let updated: Date

        public let github: URL?
        public let manifest: URL?

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
    static var unknown: Applications.Category {
        .init(
            id: "42",
            icon: .assets("UnknownCategory"),
            name: "Unknown",
            applications: 0
        )
    }

    init(_ source: Catalog.Category) {
        self.id = source.id
        self.icon = .remote(source.icon)
        self.name = source.name
        self.applications = source.applications
    }
}

extension Applications.Application {
    init(_ source: Catalog.Application) {
        self.id = source.id
        self.name = source.current.name
        self.alias = source.alias
        self.icon = source.current.icon
        self.shortDescription = source.current.shortDescription
        self.screenshots = source.current.screenshots

        self.category = .unknown
        self.status = .notInstalled

        self.version = source.current.version
        self.size = source.current.bundle?.length.hr
        self.api = source.current.build?.sdk.api
        self.description = source.current.description
        self.changelog = source.current.changelog

        self.created = source.created.date
        self.updated = source.updated.date

        self.github = source.current.links?.source.uri
        self.manifest = source.current.links?.manifest
    }
}
