import Infrared
import Foundation

public typealias InfraredButtonData = Infrared.InfraredButtonData

public struct InfraredButton: Identifiable, Equatable, Codable {
    public var id: UUID = UUID()

    public let position: InfraredButtonPosition
    public let data: InfraredButtonData

    init(_ button: Infrared.InfraredButton) {
        self.position = InfraredButtonPosition(button)
        self.data = button.data
    }

    init(position: InfraredButtonPosition, data: InfraredButtonData) {
        self.position = position
        self.data = data
    }
}
