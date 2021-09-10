extension Peripheral.Service {
    public struct DeviceInformation: Equatable, Codable {
        public var manufacturerName: Characteristic
        public var serialNumber: Characteristic
        public var firmwareRevision: Characteristic
        public var softwareRevision: Characteristic

        init(
            manufacturerName: String,
            serialNumber: String,
            firmwareRevision: String,
            softwareRevision: String
        ) {
            self.manufacturerName = .init(
                name: "Manufacturer Name",
                value: manufacturerName)
            self.serialNumber = .init(
                name: "Serial Number",
                value: serialNumber)
            self.firmwareRevision = .init(
                name: "Firmware Revision",
                value: firmwareRevision)
            self.softwareRevision = .init(
                name: "Software Revision",
                value: softwareRevision)
        }
    }
}
