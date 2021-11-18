import CoreBluetooth
import struct Foundation.UUID

public protocol BluetoothPeripheral {
    var id: UUID { get }
    var name: String { get }
    // TODO: Incapsulate CB objects
    var state: CBPeripheralState { get }
    var services: [CBService] { get }

    var info: SafePublisher<Void> { get }

    func send(_ request: Request, priority: Priority?) async throws -> Response
}

public extension BluetoothPeripheral {
    func send(_ request: Request) async throws -> Response {
        try await send(request, priority: nil)
    }
}
