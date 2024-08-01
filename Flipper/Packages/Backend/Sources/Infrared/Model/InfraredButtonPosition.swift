import Foundation

public struct InfraredButtonPosition: Decodable, Equatable {
    public let y: Int
    public let x: Int

    public let alignment: Alignment?
    public let zIndex: Double?

    public let containerWidth: Int?
    public let containerHeight: Int?

    public let contentWidth: Int?
    public let contentHeight: Int?

    init(
        y: Int,
        x: Int,
        alignment: Alignment? = nil,
        zIndex: Double? = nil,
        containerWidth: Int? = nil,
        containerHeight: Int? = nil,
        contentWidth: Int? = nil,
        contentHeight: Int? = nil
    ) {
        self.y = y
        self.x = x
        self.alignment = alignment
        self.zIndex = zIndex
        self.containerWidth = containerWidth
        self.containerHeight = containerHeight
        self.contentWidth = contentWidth
        self.contentHeight = contentHeight
    }

    public enum Alignment: String, Codable {
        case center = "CENTER"
        case topLeft = "TOP_LEFT"
        case topRight = "TOP_RIGHT"
        case bottomLeft = "BOTTOM_LEFT"
        case bottomRight = "BOTTOM_RIGHT"
        case centerLeft = "CENTER_LEFT"
        case centerRight = "CENTER_RIGHT"
    }

    enum CodingKeys: String, CodingKey {
        case x
        case y
        case alignment
        case zIndex = "z_index"
        case containerWidth = "container_width"
        case containerHeight = "container_height"
        case contentWidth = "content_width"
        case contentHeight = "content_height"
    }
}
