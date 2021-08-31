import struct Foundation.UUID

protocol BluetoothConnector {
    var peripherals: SafePublisher<[Peripheral]> { get }
    var connectedPeripheral: SafePublisher<Peripheral?> { get }
    var status: SafePublisher<BluetoothStatus> { get }

    func startScanForPeripherals()
    func stopScanForPeripherals()

    func connect(to uuid: UUID)
    func forget(about uuid: UUID)
}
