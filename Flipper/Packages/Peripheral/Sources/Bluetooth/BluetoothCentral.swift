import Combine
import struct Foundation.UUID

public protocol BluetoothCentral {
    var status: SafePublisher<BluetoothStatus> { get }
    var discovered: SafePublisher<[BluetoothPeripheral]> { get }

    func startScanForPeripherals()
    func stopScanForPeripherals()
}
