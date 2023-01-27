import Foundation

extension Array where Element == URLQueryItem {
    subscript<Key: StringProtocol>(_ key: Key) -> String? {
        first(where: { $0.name == key })?.value
    }

    var plusPercentEncoded: String? {
        var items: [String] = []
        for queryItem in self {
            guard
                let encodedName = QueryCoder.encode(queryItem.name),
                let encodedValue = QueryCoder.encode(queryItem.value ?? "")
            else {
                return nil
            }
            items.append("\(encodedName)=\(encodedValue)")
        }
        return items.joined(separator: "&")
    }

    init?(plusPercentEncoded string: String) {
        var components = URLComponents()
        components.query = string
        guard let queryItems = components.queryItems else {
            return nil
        }
        var result: [URLQueryItem] = []
        for item in queryItems {
            switch item.value {
            case .some(let value):
                guard
                    let name = QueryCoder.decode(item.name),
                    let value = QueryCoder.decode(value)
                else {
                    return nil
                }
                result.append(.init(name: name, value: value))
            case .none:
                guard let name = QueryCoder.decode(item.name) else {
                    return nil
                }
                result.append(.init(name: name, value: nil))
            }
        }
        self = result
    }

    mutating func append<Name: StringProtocol, Value: StringProtocol>(
        name: Name,
        value: Value?
    ) {
        if let value = value {
            self.append(.init(name: .init(name), value: .init(value)))
        } else {
            self.append(.init(name: .init(name), value: nil))
        }
    }
}
