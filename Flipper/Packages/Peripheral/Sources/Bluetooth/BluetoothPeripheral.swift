import Combine
import CoreBluetooth
import struct Foundation.UUID

public protocol BluetoothPeripheral: AnyObject {
    var id: UUID { get }
    var name: String { get }
    var color: FlipperColor { get }
    var state: FlipperState { get }
    var services: [FlipperService] { get }

    var maximumWriteValueLength: Int { get }

    var info: AnyPublisher<Void, Never> { get }
    var canWrite: AnyPublisher<Void, Never> { get }
    var received: AnyPublisher<Data, Never> { get }

    func onConnecting()
    func onConnect()
    func onDisconnect()
    func onError(_ error: Swift.Error)

    func send(_ data: Data)
}

public extension BluetoothPeripheral {
    // swiftlint:disable discouraged_optional_boolean

    private func hasCharacteristic(_ id: String) -> Bool? {
        guard !services.isEmpty else {
            return nil
        }
        return services.contains { service in
            service.characteristics.contains { $0.id == id }
        }
    }

    var hasProtobufVersion: Bool? {
        hasCharacteristic("03F6666D-AE5E-47C8-8E1A-5D873EB5A933")
    }

    var hasBatteryPowerState: Bool? {
        hasCharacteristic("Battery Power State")
    }
}

public enum FlipperColor: String, Equatable {
    case unknown
    case black
    case white
}

public enum FlipperState: Equatable {
    case disconnected
    case connecting
    case connected
    case disconnecting
    case pairingFailed
    case invalidPairing
}

public struct FlipperService: Equatable, Identifiable {
    public var id: String { name }

    public var name: String
    public var characteristics: [Characteristic] = []

    public struct Characteristic: Equatable, Identifiable {
        public var id: String { name }

        public var name: String
        public var value: [UInt8]
    }
}
