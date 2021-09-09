import struct Foundation.UUID

public protocol BluetoothCentral {
    var status: SafePublisher<BluetoothStatus> { get }
    var peripherals: SafePublisher<[Peripheral]> { get }

    func startScanForPeripherals()
    func stopScanForPeripherals()
}
