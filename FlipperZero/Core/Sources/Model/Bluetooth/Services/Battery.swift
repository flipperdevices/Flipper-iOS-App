extension Peripheral.Service {
    public struct Battery: Equatable {
        public let level: Characteristic

        init(level: Int) {
            self.level = .init(name: "Battery Level", value: .init(level))
        }
    }
}
