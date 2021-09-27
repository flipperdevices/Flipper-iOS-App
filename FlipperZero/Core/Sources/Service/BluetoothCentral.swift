import struct Foundation.UUID

public protocol BluetoothCentral {
    var status: SafePublisher<BluetoothStatus> { get }
    var peripherals: SafePublisher<[BluetoothPeripheral]> { get }

    func startScanForPeripherals()
    func stopScanForPeripherals()
}
