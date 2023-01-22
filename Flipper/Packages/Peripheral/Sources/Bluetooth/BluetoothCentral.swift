import Combine
import struct Foundation.UUID

public protocol BluetoothCentral {
    var status: SafePublisher<BluetoothStatus> { get }
    var discovered: SafePublisher<[BluetoothPeripheral]> { get }
    var connected: SafePublisher<[BluetoothPeripheral]> { get }

    func startScanForPeripherals()
    func stopScanForPeripherals()

    func connect(to uuid: UUID)
    func disconnect(from uuid: UUID)
}
