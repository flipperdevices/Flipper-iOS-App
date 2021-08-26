protocol EquatableById: Equatable {}

extension EquatableById where Self: Identifiable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}
