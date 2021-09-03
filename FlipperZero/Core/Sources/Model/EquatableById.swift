public protocol EquatableById: Equatable {}

extension EquatableById where Self: Identifiable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}
