import Catalog
import Foundation

public struct Category: Identifiable, Hashable {
    public let id: String
    public let name: String
    public let icon: URL
    public let applications: Int

    public init(
        id: String,
        name: String,
        icon: URL,
        applications: Int
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.applications = applications
    }
}

extension Category {
    init(_ other: Catalog.Category) {
        self.init(
            id: other.id,
            name: other.name,
            icon: other.icon,
            applications: other.applications)
    }
}
