import Foundation

public enum ImageSource: Equatable, Decodable {
    case url(URL)
    case data(Data)

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        self = string.starts(with: "https")
            ? .url(.init(string: string)!)
            : .data(.init(base64Encoded: string)!)
    }

    public var url: URL? {
        switch self {
        case .url(let url): return url
        default: return nil
        }
    }
}
