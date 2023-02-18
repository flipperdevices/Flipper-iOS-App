import Combine
import struct Foundation.UUID

public protocol BluetoothCentral {
    var status: AnyPublisher<BluetoothStatus, Never> { get }
    var discovered: AnyPublisher<[BluetoothPeripheral], Never> { get }
    var connected: AnyPublisher<[BluetoothPeripheral], Never> { get }

    func startScanForPeripherals()
    func stopScanForPeripherals()

    func connect(to uuid: UUID)
    func disconnect(from uuid: UUID)
}
