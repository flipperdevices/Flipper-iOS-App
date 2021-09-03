import struct Foundation.UUID

public struct Peripheral: EquatableById, Identifiable {
    public let id: UUID
    public let name: String
    public var state: State = .disconnected
    public var services: [Service] = []

    public init(
        id: UUID,
        name: String,
        state: Peripheral.State = .disconnected,
        services: [Peripheral.Service] = []
    ) {
        self.id = id
        self.name = name
        self.state = state
        self.services = services
    }

    public enum State {
        case disconnected
        case connecting
        case connected
        case disconnecting
    }

    public struct Service: Identifiable {
        public var id: String { name }

        public var name: String
        public var characteristics: [Characteristic] = []

        // swiftlint:disable nesting
        public struct Characteristic: Identifiable {
            public var id: String { name }

            public let name: String
            public let value: String
        }
    }
}
