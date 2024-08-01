import Foundation

public struct InfraredButton: Decodable, Equatable {
    public let data: InfraredButtonData
    public let position: InfraredButtonPosition

    enum CodingKeys: String, CodingKey {
        case data
        case position
    }
}
