import struct Foundation.UUID

// FIXME: this is actually UI model, move there

public struct Peripheral: Equatable, Codable, Identifiable {
    public let id: UUID
    public let name: String
    public var state: State = .disconnected
    public var deviceInformation: Service.DeviceInformation?
    public var battery: Service.Battery?

    public init(
        id: UUID,
        name: String,
        state: Peripheral.State = .disconnected,
        deviceInformation: Service.DeviceInformation? = nil,
        battery: Service.Battery? = nil
    ) {
        self.id = id
        self.name = name
        self.state = state
        self.deviceInformation = deviceInformation
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
            public var value: String
        }
    }
}

import CoreBluetooth

public extension Peripheral {
    init(_ source: BluetoothPeripheral) {
        self.id = source.id
        self.name = source.name
        self.state = .init(source.state)

        self.deviceInformation = source.services
            .first { $0.uuid == .deviceInformation }
            .map(Service.DeviceInformation.init) ?? nil

        self.battery = source.services
            .first { $0.uuid == .battery }
            .map(Service.Battery.init) ?? nil
    }
}

fileprivate extension Peripheral.State {
    init(_ source: CBPeripheralState) {
        // swiftlint:disable switch_case_on_newline
        switch source {
        case .disconnected: self = .disconnected
        case .connecting: self = .connecting
        case .connected: self = .connected
        case .disconnecting: self = .disconnecting
        @unknown default: self = .disconnected
        }
    }
}

fileprivate extension Peripheral.Service.DeviceInformation {
    init?(_ source: CBService) {
        guard source.uuid == .deviceInformation else { return nil }
        self.init(manufacturerName: "", serialNumber: "", firmwareRevision: "", softwareRevision: "")
        source.characteristics?.forEach {
            switch $0.uuid.description.dropLast(" String".count) {
            case manufacturerName.name: self.manufacturerName.value = parse($0.value)
            case serialNumber.name: self.serialNumber.value = parse($0.value)
            case firmwareRevision.name: self.firmwareRevision.value = parse($0.value)
            case softwareRevision.name: self.softwareRevision.value = parse($0.value)
            default: return
            }
        }
    }

    private func parse(_ data: Data?) -> String {
        guard let data = data else { return "" }
        return String(data: data, encoding: .utf8) ?? ""
    }
}

fileprivate extension Peripheral.Service.Battery {
    init?(_ source: CBService) {
        guard
            source.uuid == .battery,
            let level = source.characteristics?.first,
            let data = level.value, data.count == 1
        else {
            return nil
        }
        self.init(level: Int(data[0]))
    }
}

extension Peripheral.Service {
    init(_ source: CBService) {
        self.name = source.uuid.description
        self.characteristics = source.characteristics?.map(Characteristic.init) ?? []
    }
}

extension Peripheral.Service.Characteristic {
    init(_ source: CBCharacteristic) {
        self.name = source.uuid.description
        switch source.value {
        case let .some(data):
            self.value = String(data: data, encoding: .utf8) ?? ""
        case .none:
            self.value = ""
        }
    }
}
