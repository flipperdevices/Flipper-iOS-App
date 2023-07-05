import Foundation

// TODO: Move to Core.Next

extension URL: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        guard let url = URL(string: value) else {
            fatalError("invalid url")
        }
        self = url
    }
}
