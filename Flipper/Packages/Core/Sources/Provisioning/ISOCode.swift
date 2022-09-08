public struct ISOCode: Equatable, Hashable {
    var value: String

    static var `default`: Self {
        .init("WW").unsafelyUnwrapped
    }

    init?(_ string: String) {
        guard string.count == 2 else {
            return nil
        }
        self.value = string.uppercased()
    }
}

extension ISOCode: CustomStringConvertible {
    public var description: String {
        return value
    }
}
