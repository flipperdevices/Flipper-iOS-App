import Foundation

public struct InfraredButton: Decodable, Equatable, Identifiable {
    public let id: UUID = UUID()

    public let data: InfraredButtonData
    public let position: InfraredButtonPosition

    enum CodingKeys: String, CodingKey {
        case data
        case position
        case type
    }

    public static func == (rhs: InfraredButton, lhs: InfraredButton) -> Bool {
        return rhs.data == lhs.data && rhs.position == lhs.position
    }

    init(data: InfraredButtonData, position: InfraredButtonPosition) {
        self.data = data
        self.position = position
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.position = try container.decode(
            InfraredButtonPosition.self,
            forKey: .position)
        self.data = try Self.getInfraredButtonData(container: container)
    }

    static func getInfraredButtonData(
        container: KeyedDecodingContainer<CodingKeys>
    ) throws -> InfraredButtonData {
        let dataContainer = try container.nestedContainer(
            keyedBy: CodingKeys.self,
            forKey: .data)

        guard let type = try? dataContainer.decode(
            InfraredButtonDataType.self,
            forKey: .type)
        else { return .unknown }

        switch type {
        case .text:
            let data = try container.decode(TextButtonData.self, forKey: .data)
            return .text(data)
        case .icon:
            let data = try container.decode(IconButtonData.self, forKey: .data)
            return .icon(data)
        case .base64Image:
            let data = try container.decode(
                Base64ImageButtonData.self,
                forKey: .data)
            return .base64Image(data)
        case .navigation:
            let data = try container.decode(
                NavigationButtonData.self,
                forKey: .data)
            return .navigation(data)
        case .channel:
            let data = try container.decode(
                ChannelButtonData.self,
                forKey: .data)
            return .channel(data)
        case .volume:
            let data = try container.decode(
                VolumeButtonData.self,
                forKey: .data)
            return .volume(data)
        }
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
