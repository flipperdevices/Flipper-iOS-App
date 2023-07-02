import Foundation

public struct Category: Decodable {
    public let id: String
    public let priority: Int
    public let name: String
    public let color: String
    public let icon: URL
    public let applications: Int

    public init(
        id: String,
        priority: Int,
        name: String,
        color: String,
        icon: URL,
        applications: Int
    ) {
        self.id = id
        self.priority = priority
        self.name = name
        self.color = color
        self.icon = icon
        self.applications = applications
    }

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case priority
        case name
        case color
        case icon = "icon_uri"
        case applications
    }
}
