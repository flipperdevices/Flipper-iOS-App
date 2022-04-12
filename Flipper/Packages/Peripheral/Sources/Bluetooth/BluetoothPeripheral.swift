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
    var hasProtobufVersion: Bool? {
        guard !services.isEmpty else {
            return nil
        }
        return services.contains { service in
            service.characteristics.contains { characteristic in
                characteristic.id == "03F6666D-AE5E-47C8-8E1A-5D873EB5A933"
            }
        }
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

    /// swiftlint:disable nesting
    public struct Characteristic: Equatable, Identifiable {
        public var id: String { name }

        public var name: String
        public var value: [UInt8]
    }
}
