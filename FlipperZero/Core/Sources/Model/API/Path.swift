public struct Path {
    var components: [String]

    public var isEmpty: Bool {
        components.isEmpty
    }

    public init(components: [String] = []) {
        self.components = components
    }

    public var string: String {
        components.reduce(into: "") {
            $0.append("/" + $1)
        }
    }

    public mutating func append(_ component: String) {
        // TODO: validate input
        components.append(component)
    }

    @discardableResult
    public mutating func removeLastComponent() -> String? {
        guard !components.isEmpty else { return nil }
        return components.removeLast()
    }
}
