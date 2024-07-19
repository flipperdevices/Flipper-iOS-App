import Foundation

public struct InfraredButton: Decodable, Equatable, Identifiable {
    public var id: UUID = UUID()

    public let data: InfraredButtonData
    public let position: InfraredButtonPosition

    enum CodingKeys: String, CodingKey {
        case data
        case position
    }
}

public extension InfraredButton {
    var containerWidth: Double {
        Double(position.containerWidth ?? data.containerDefaultWidth)
    }

    var containerHeight: Double {
        Double(position.containerHeight ?? data.containerDefaultHeight)
    }

    var x: Double { Double(position.x) }

    var y: Double { Double(position.y) }

    var zIndex: Double { position.zIndex ?? 1.0 }

    var contentWidth: Double {
        Double(position.contentWidth ?? data.contentDefaultWidth)
    }

    var contentHeight: Double {
        Double(position.contentHeight ?? data.contentDefaultHeight)
    }

    var alignment: InfraredButtonPosition.Alignment {
        position.alignment ?? .center
    }
}
