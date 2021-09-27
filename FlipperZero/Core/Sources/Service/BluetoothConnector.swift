import struct Foundation.UUID

public protocol BluetoothConnector {
    var status: SafePublisher<BluetoothStatus> { get }
    var connectedPeripherals: SafePublisher<[BluetoothPeripheral]> { get }

    func connect(to uuid: UUID)
    func disconnect(from uuid: UUID)
}
