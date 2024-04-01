import Foundation
import Catalog

public struct Application: Identifiable, Equatable {
    public typealias ID = Catalog.Application.ID
    public typealias BuildStatus = Catalog.Application.Status

    private var application: Catalog.Application

    public var category: Category


    init(
        application: Catalog.Application,
        category: Category
    ) {
        self.application = application
        self.category = category
    }

    init(
        application: Catalog.Application,
        category: String
    ) {
        self.application = application
        self.category = .init(name: category)
    }

    public struct Category: Equatable {
        public let icon: Catalog.ImageSource
        public let name: String

        init(category: Applications.Category) {
            self.icon = .url(category.icon)
            self.name = category.name
        }

        init(name: String) {
            self.icon = .data(.init())
            self.name = name
        }
    }

    public var id: ID { application.id }
    public var alias: String { application.alias }
    public var created: Date { application.created.date }
    public var updated: Date { application.updated.date }
    public var current: Catalog.Application.Current { application.current }
}
