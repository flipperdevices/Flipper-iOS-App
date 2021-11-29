extension Peripheral.Service {
    public struct Battery: Equatable, Codable {
        public let level: Int

        public var decimalValue: Double {
            Double(level) / 100
        }
    }
}
