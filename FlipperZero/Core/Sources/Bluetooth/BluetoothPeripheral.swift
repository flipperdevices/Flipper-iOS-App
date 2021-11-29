import CoreBluetooth
import struct Foundation.UUID

public protocol BluetoothPeripheral: AnyObject {
    var id: UUID { get }
    var name: String { get }
    var state: Peripheral.State { get }
    // TODO: Incapsulate CB objects
    var services: [CBService] { get }

    var info: SafePublisher<Void> { get }
    var delegate: PeripheralDelegate? { get set }

    func send(_ data: Data)
}
