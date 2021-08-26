import struct Foundation.UUID

struct Peripheral: EquatableById, Identifiable {
    let id: UUID
    let name: String
    var state: State = .disconnected
    var services: [Service] = []

    enum State {
        case disconnected
        case connecting
        case connected
        case disconnecting
    }

    struct Service: Identifiable {
        var id: String { name }

        var name: String
        var characteristics: [Characteristic] = []

        // swiftlint:disable nesting
        struct Characteristic: Identifiable {
            var id: String { name }

            let name: String
            let value: String
        }
    }
}
