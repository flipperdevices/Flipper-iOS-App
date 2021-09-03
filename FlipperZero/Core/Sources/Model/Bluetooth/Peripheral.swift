import struct Foundation.UUID

// FIXME: this is actually UI model, move there

public struct Peripheral: Equatable, Identifiable {
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

    public enum State: Equatable {
        case disconnected
        case connecting
        case connected
        case disconnecting
    }

    public struct Service: Equatable, Identifiable {
        public var id: String { name }

        public var name: String
        public var characteristics: [Characteristic] = []

        // swiftlint:disable nesting
        public struct Characteristic: Equatable, Identifiable {
            public var id: String { name }

            public let name: String
            public let value: String
        }
    }
}
