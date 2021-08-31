import struct Foundation.UUID

protocol LocalStorage {
    var lastConnectedDevice: UUID? { get set }
}
