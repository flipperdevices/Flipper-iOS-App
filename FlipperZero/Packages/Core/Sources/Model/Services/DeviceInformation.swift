extension Peripheral.Service {
    public struct DeviceInformation: Equatable, Codable {
        public var manufacturerName: String
        public var serialNumber: String
        public var firmwareRevision: String
        public var softwareRevision: String
    }
}

extension Peripheral.Service.DeviceInformation {
    init(
        manufacturerName: [UInt8],
        serialNumber: [UInt8],
        firmwareRevision: [UInt8],
        softwareRevision: [UInt8]
    ) {
        self.manufacturerName = .init(decoding: manufacturerName, as: UTF8.self)
        self.serialNumber = .init(decoding: serialNumber, as: UTF8.self)
        self.firmwareRevision = .init(decoding: firmwareRevision, as: UTF8.self)
        self.softwareRevision = .init(decoding: softwareRevision, as: UTF8.self)
    }
}
