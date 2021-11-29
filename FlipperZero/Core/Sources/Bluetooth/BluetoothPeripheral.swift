import CoreBluetooth
import struct Foundation.UUID

public protocol BluetoothPeripheral: AnyObject {
    var id: UUID { get }
    var name: String { get }
    var state: Peripheral.State { get }
    var services: [Peripheral.Service] { get }

    var info: SafePublisher<Void> { get }
    var delegate: PeripheralDelegate? { get set }

    func send(_ data: Data)
}
