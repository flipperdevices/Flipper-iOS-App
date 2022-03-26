public struct Path: Equatable, Hashable, Codable {
    var components: [String]

    public var isEmpty: Bool {
        components.isEmpty
    }

    public var lastComponent: String? {
        components.last
    }

    public init(string: String) {
        self.components = string.split(separator: "/").map(String.init)
    }

    public init(components: [String] = []) {
        self.components = components
    }

    public var string: String {
        guard !components.isEmpty else {
            return "/"
        }
        return components.reduce(into: "") {
            $0.append("/" + $1)
        }
    }

    public mutating func append(_ component: String) {
        // TODO: validate input
        components.append(component)
    }

    public func appending(_ component: String) -> Path {
        var path = self
        path.append(component)
        return path
    }

    @discardableResult
    public mutating func removeLastComponent() -> String? {
        guard !components.isEmpty else { return nil }
        return components.removeLast()
    }
}

extension Path: CustomStringConvertible {
    public var description: String { string }
}

extension Path: ExpressibleByStringInterpolation {
    public init(stringLiteral: String) {
        self.init(string: stringLiteral)
    }
}
