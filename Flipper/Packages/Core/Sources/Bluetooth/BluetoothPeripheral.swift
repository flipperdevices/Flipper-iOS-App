import CoreBluetooth
import struct Foundation.UUID

public protocol BluetoothPeripheral: AnyObject {
    var id: UUID { get }
    var name: String { get }
    var color: Peripheral.Color { get }
    var state: Peripheral.State { get }
    var services: [Peripheral.Service] { get }

    var isPairingFailed: Bool { get }
    var hasProtobufVersion: Bool { get }
    var didDiscoverDeviceInformation: Bool { get }

    var maximumWriteValueLength: Int { get }

    var info: SafePublisher<Void> { get }
    var canWrite: SafePublisher<Void> { get }
    var received: SafePublisher<Data> { get }

    func send(_ data: Data)
}
