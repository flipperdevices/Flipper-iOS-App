import Foundation

public struct TimeStamp: Decodable {
    public let date: Date

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let timestamp = try container.decode(Int.self)
        self.date = .init(timeIntervalSince1970: .init(timestamp))
    }
}
