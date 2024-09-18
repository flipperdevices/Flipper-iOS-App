import Foundation

public struct InfraredButton: Codable, Equatable {
    public let data: InfraredButtonData
    public let position: InfraredButtonPosition

    public init(data: InfraredButtonData, position: InfraredButtonPosition) {
        self.data = data
        self.position = position
    }
}
