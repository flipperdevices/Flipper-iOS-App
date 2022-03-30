extension Flipper {
    public struct Battery: Equatable {
        public let level: Int

        public var decimalValue: Double {
            Double(level) / 100
        }
    }
}
