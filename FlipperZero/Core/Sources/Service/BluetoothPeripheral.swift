import CoreBluetooth
import struct Foundation.UUID

public protocol BluetoothPeripheral {
    var id: UUID { get }
    var name: String { get }
    // TODO: Incapsulate CB objects
    var state: CBPeripheralState { get }
    var services: [CBService] { get }

    func send(_ bytes: [UInt8])

    var info: SafePublisher<Void> { get }
    var received: SafePublisher<[UInt8]> { get }
}
