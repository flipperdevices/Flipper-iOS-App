import Combine
import CoreBluetooth
import struct Foundation.UUID

public protocol BluetoothPeripheral: AnyObject {
    var id: UUID { get }
    var name: String { get }
    var color: FlipperColor { get }
    var state: FlipperState { get }
    var services: [FlipperService] { get }

    var isPairingFailed: Bool { get }
    var hasProtobufVersion: Bool { get }
    var didDiscoverDeviceInformation: Bool { get }

    var maximumWriteValueLength: Int { get }

    var info: AnyPublisher<Void, Never> { get }
    var canWrite: AnyPublisher<Void, Never> { get }
    var received: AnyPublisher<Data, Never> { get }

    func onConnect()
    func onDisconnect()
    func onError(_ error: Swift.Error)

    func send(_ data: Data)
}

public enum FlipperColor: Equatable, Codable {
    case unknown
    case black
    case white
}

public enum FlipperState: Equatable, Codable {
    case disconnected
    case connecting
    case connected
    case disconnecting
}

public struct FlipperService: Equatable, Codable, Identifiable {
    public var id: String { name }

    public var name: String
    public var characteristics: [Characteristic] = []

    /// swiftlint:disable nesting
    public struct Characteristic: Equatable, Codable, Identifiable {
        public var id: String { name }

        public var name: String
        public var value: [UInt8]
    }
}
