import CoreBluetooth
import struct Foundation.UUID

public protocol BluetoothPeripheral {
    var id: UUID { get }
    var name: String { get }
    // TODO: Incapsulate CB objects
    var state: CBPeripheralState { get }
    var services: [CBService] { get }

    var info: SafePublisher<Void> { get }

    func send(
        _ request: Request,
        priority: Priority?,
        continuation: @escaping Continuation
    )
}

public extension BluetoothPeripheral {
    func send(_ request: Request, continuation: @escaping Continuation) {
        send(request, priority: nil, continuation: continuation)
    }
}
