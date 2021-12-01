public protocol EquatableById: Equatable {}

public extension EquatableById where Self: Identifiable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}
