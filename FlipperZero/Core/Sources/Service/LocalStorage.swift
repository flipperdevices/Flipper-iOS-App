import struct Foundation.UUID

public protocol LocalStorage {
    var lastConnectedDevice: UUID? { get set }
}
