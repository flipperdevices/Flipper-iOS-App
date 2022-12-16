import Foundation

public struct Category: Decodable {
    public let id: String
    public let priority: Int
    public let name: String
    public let color: String
    public let icon: URL

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case priority
        case name
        case color
        case icon = "icon_uri"
    }
}
