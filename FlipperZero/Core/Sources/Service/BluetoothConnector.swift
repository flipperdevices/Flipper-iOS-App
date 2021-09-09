import struct Foundation.UUID

public protocol BluetoothConnector {
    var status: SafePublisher<BluetoothStatus> { get }
    var connectedPeripherals: SafePublisher<[Peripheral]> { get }

    func connect(to uuid: UUID)
    func disconnect(from uuid: UUID)

    // TODO: move to BluetoothDevice
    var received: SafePublisher<[UInt8]> { get }

    func send(_ bytes: [UInt8], to identifier: UUID)
}
