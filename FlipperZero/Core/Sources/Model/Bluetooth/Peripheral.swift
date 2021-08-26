import struct Foundation.UUID

struct Peripheral: EquatableById, Identifiable {
    let id: UUID
    let name: String
}
