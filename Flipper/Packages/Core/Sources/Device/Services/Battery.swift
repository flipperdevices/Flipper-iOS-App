extension Flipper {
    // swiftlint:disable nesting
    public struct Battery: Equatable {
        public let level: Int
        public let state: State

        public var decimalValue: Double {
            Double(level) / 100
        }

        public enum State {
            case charging
            case discharging
        }
    }
}
