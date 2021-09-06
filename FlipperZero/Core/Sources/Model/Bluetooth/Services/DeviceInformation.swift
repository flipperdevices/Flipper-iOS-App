extension Peripheral.Service {
    public struct DeviceInformation: Equatable {
        public var manufacturerName: Characteristic
        public var modelNumber: Characteristic
        public var firmwareRevision: Characteristic
        public var softwareRevision: Characteristic

        init(
            manufacturerName: String,
            modelNumber: String,
            firmwareRevision: String,
            softwareRevision: String
        ) {
            self.manufacturerName = .init(
                name: "Manufacturer Name",
                value: manufacturerName)
            self.modelNumber = .init(
                name: "Model Number",
                value: modelNumber)
            self.firmwareRevision = .init(
                name: "Firmware Revision",
                value: firmwareRevision)
            self.softwareRevision = .init(
                name: "Software Revision",
                value: softwareRevision)
        }
    }
}
