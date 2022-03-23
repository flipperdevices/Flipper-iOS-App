import struct Foundation.UUID

// FIXME: this is actually UI model, move there

public struct Peripheral: Equatable, Codable, Identifiable {
    public let id: UUID
    public let name: String
    public var color: Color
    public var state: State = .disconnected
    public var information: Service.DeviceInformation?
    public var battery: Service.Battery?
    public var storage: StorageInfo?

    public var isUnsupported = false

    public enum Color: Codable {
        case unknown
        case black
        case white
    }

    public init(
        id: UUID,
        name: String,
        color: Color,
        state: Peripheral.State = .disconnected,
        information: Service.DeviceInformation? = nil,
        battery: Service.Battery? = nil
    ) {
        self.id = id
        self.name = name
        self.color = color
        self.state = state
        self.information = information
        self.battery = battery
    }

    public enum State: Equatable, Codable {
        case disconnected
        case connecting
        case connected
        case disconnecting
    }

    public struct Service: Equatable, Codable, Identifiable {
        public var id: String { name }

        public var name: String
        public var characteristics: [Characteristic] = []

        // swiftlint:disable nesting
        public struct Characteristic: Equatable, Codable, Identifiable {
            public var id: String { name }

            public var name: String
            public var value: [UInt8]
        }
    }

    public struct StorageInfo: Equatable, Codable {
        public var `internal`: StorageSpace?
        public var external: StorageSpace?
    }
}

fileprivate extension String {
    static var deviceInformation: String { "Device Information" }
    static var battery: String { "Battery" }
}

public extension Peripheral {
    init(_ source: BluetoothPeripheral) {
        self.id = source.id
        self.name = source.name
        self.color = source.color
        self.state = source.state

        self.information = source.services
            .first { $0.id == .deviceInformation }
            .map(Service.DeviceInformation.init) ?? nil

        self.battery = source.services
            .first { $0.id == .battery }
            .map(Service.Battery.init) ?? nil

        self.isUnsupported = !source.hasProtobufVersion
    }
}

fileprivate extension String {
    static var manufacturerName: String { "Manufacturer Name String" }
    static var serialNumber: String { "Serial Number String" }
    static var firmwareRevision: String { "Firmware Revision String" }
    static var softwareRevision: String { "Software Revision String" }
    static var protobufUUID: String { "03F6666D-AE5E-47C8-8E1A-5D873EB5A933" }
}

fileprivate extension Peripheral.Service.DeviceInformation {
    init?(_ service: Peripheral.Service) {
        guard service.id == .deviceInformation else { return nil }

        let manufacturerName = service.characteristics
            .first { $0.name == .manufacturerName }?.value ?? []
        let serialNumber = service.characteristics
            .first { $0.name == .serialNumber }?.value ?? []
        let firmwareRevision = service.characteristics
            .first { $0.name == .firmwareRevision }?.value ?? []
        let softwareRevision = service.characteristics
            .first { $0.name == .softwareRevision }?.value ?? []
        let protobufRevision = service.characteristics
            .first { $0.name == .protobufUUID }?.value ?? []

        self.init(
            manufacturerName: manufacturerName,
            serialNumber: serialNumber,
            firmwareRevision: firmwareRevision,
            softwareRevision: softwareRevision,
            protobufRevision: protobufRevision)
    }
}

fileprivate extension Peripheral.Service.Battery {
    init?(_ service: Peripheral.Service) {
        guard
            service.id == .battery,
            let characteristic = service.characteristics.first,
            !characteristic.value.isEmpty
        else {
            return nil
        }
        self.init(level: Int(characteristic.value[0]))
    }
}
