import struct Foundation.UUID

public protocol BluetoothConnector {
    var peripherals: SafePublisher<[Peripheral]> { get }
    var connectedPeripheral: SafePublisher<Peripheral?> { get }
    var status: SafePublisher<BluetoothStatus> { get }

    func startScanForPeripherals()
    func stopScanForPeripherals()

    func connect(to uuid: UUID)
    func forget(about uuid: UUID)

    func send(_ bytes: [UInt8])
    var received: SafePublisher<[UInt8]> { get }
}
