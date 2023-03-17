import Peripheral

extension Flipper {
    public struct DeviceInformation: Equatable {
        public var manufacturerName: String
        public var serialNumber: String
        public var firmwareRevision: String
        public var softwareRevision: String
        public var protobufRevision: ProtobufVersion
    }
}

extension Flipper.DeviceInformation {
    init(
        manufacturerName: [UInt8],
        serialNumber: [UInt8],
        firmwareRevision: [UInt8],
        softwareRevision: [UInt8],
        protobufRevision: [UInt8]
    ) {
        self.manufacturerName = .init(decoding: manufacturerName, as: UTF8.self)
        self.serialNumber = .init(decoding: serialNumber, as: UTF8.self)
        self.firmwareRevision = .init(decoding: firmwareRevision, as: UTF8.self)
        self.softwareRevision = .init(decoding: softwareRevision, as: UTF8.self)
        self.protobufRevision = .init(decoding: protobufRevision, as: UTF8.self)
    }
}
