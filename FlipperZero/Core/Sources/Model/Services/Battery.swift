extension Peripheral.Service {
    public struct Battery: Equatable, Codable {
        public let level: Characteristic

        public var decimalValue: Double {
            (Double(level.value) ?? 0) / 100
        }

        init(level: Int) {
            self.level = .init(name: "Battery Level", value: .init(level))
        }
    }
}
