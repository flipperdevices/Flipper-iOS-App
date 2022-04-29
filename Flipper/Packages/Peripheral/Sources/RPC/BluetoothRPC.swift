import Inject
import Combine
import Logging
import struct Foundation.Date

public class BluetoothRPC: RPC {
    private let logger = Logger(label: "rpc")

    @Inject private var connector: BluetoothConnector
    private var connectorHandle: AnyCancellable?
    private var peripheralHandle: AnyCancellable?

    public var session: Session?
    private var peripheral: BluetoothPeripheral? {
        didSet { self.peripheralDidChange() }
    }
    private var onScreenFrame: ((ScreenFrame) -> Void)?

    init() {
        connectorHandle = connector.connected
            .map { $0.first }
            .assign(to: \.peripheral, on: self)
    }

    private func peripheralDidChange() {
        peripheralHandle = peripheral?.info
            .sink { [weak self] in
                self?.updateSession()
            }
    }

    private func updateSession() {
        guard let peripheral = peripheral, peripheral.state == .connected else {
            session = nil
            return
        }
        guard session == nil else { return }
        self.session = FlipperSession(peripheral: peripheral)
        self.session?.onMessage = self.onMessage
        self.session?.onError = self.onError
    }

    private func onMessage(_ message: Message) {
        switch message {
        case .decodeError:
            onError(.common(.decode))
        case .screenFrame(let screenFrame):
            onScreenFrame?(screenFrame)
        case .unknown(let command):
            logger.error("unexpected message: \(command)")
        case .reboot:
            fatalError("unreachable")
        }
    }

    private func onError(_ error: Error) {
        logger.error("\(error)")
        reconnect()
    }

    private func reconnect() {
        if let peripheral = peripheral {
            connector.disconnect(from: peripheral.id)
            connector.connect(to: peripheral.id)
        }
    }
}

// MARK: Public methods

extension BluetoothRPC {
    public func deviceInfo(
        priority: Priority?
    ) async throws -> [String: String] {
        let response = try await session?.send(
            .system(.info),
            priority: priority)
        guard case .system(.info(let result)) = response else {
            throw Error.unexpectedResponse(response)
        }
        return result
    }

    @discardableResult
    public func ping(
        _ bytes: [UInt8],
        priority: Priority?
    ) async throws -> [UInt8] {
        let response = try await session?.send(
            .system(.ping(bytes)),
            priority: priority)
        guard case .system(.ping(let result)) = response else {
            throw Error.unexpectedResponse(response)
        }
        return result
    }

    public func reboot(
        to mode: Message.RebootMode,
        priority: Priority?
    ) async throws {
        try await session?.send(.reboot(mode), priority: priority)
    }

    public func getDate(priority: Priority?) async throws -> Date {
        let response = try await session?.send(
            .system(.getDate),
            priority: priority)
        guard case .system(.dateTime(let result)) = response else {
            throw Error.unexpectedResponse(response)
        }
        return result
    }

    public func setDate(_ date: Date, priority: Priority?) async throws {
        let response = try await session?.send(
            .system(.setDate(date)),
            priority: priority)
        guard case .ok = response else {
            throw Error.unexpectedResponse(response)
        }
    }

    public func update(manifest: String, priority: Priority?) async throws {
        let response = try await session?.send(
            .system(.update(manifest)),
            priority: priority)
        guard case .ok = response else {
            throw Error.unexpectedResponse(response)
        }
    }

    public func getStorageInfo(
        at path: Path,
        priority: Priority?
    ) async throws -> StorageSpace {
        let response = try await session?.send(
            .storage(.info(path)),
            priority: priority)
        guard case .storage(.info(let result)) = response else {
            throw Error.unexpectedResponse(response)
        }
        return result
    }

    public func listDirectory(
        at path: Path,
        priority: Priority?
    ) async throws -> [Element] {
        let response = try await session?.send(
            .storage(.list(path)),
            priority: priority)
        guard case .storage(.list(let items)) = response else {
            throw Error.unexpectedResponse(response)
        }
        return items
    }

    public func createFile(
        at path: Path,
        isDirectory: Bool,
        priority: Priority?
    ) async throws {
        let response = try await session?.send(
            .storage(.create(path, isDirectory: isDirectory)),
            priority: priority)
        guard case .ok = response else {
            throw Error.unexpectedResponse(response)
        }
    }

    public func deleteFile(
        at path: Path,
        force: Bool,
        priority: Priority?
    ) async throws {
        let response = try await session?.send(
            .storage(.delete(path, isForce: force)),
            priority: priority
        )
        guard case .ok = response else {
            throw Error.unexpectedResponse(response)
        }
    }

    public func readFile(
        at path: Path,
        priority: Priority? = nil
    ) async throws -> [UInt8] {
        let response = try await session?.send(
            .storage(.read(path)),
            priority: priority)
        guard case .storage(.file(let bytes)) = response else {
            throw Error.unexpectedResponse(response)
        }
        return bytes
    }

    public func writeFile(
        at path: Path,
        bytes: [UInt8],
        priority: Priority?
    ) async throws {
        let response = try await session?.send(
            .storage(.write(path, bytes)),
            priority: priority)
        guard case .ok = response else {
            throw Error.unexpectedResponse(response)
        }
    }

    public func moveFile(
        from: Path,
        to: Path,
        priority: Priority?
    ) async throws {
        let response = try await session?.send(
            .storage(.move(from, to)),
            priority: priority)
        guard case .ok = response else {
            throw Error.unexpectedResponse(response)
        }
    }

    public func calculateFileHash(
        at path: Path,
        priority: Priority?
    ) async throws -> Hash {
        let response = try await session?.send(
            .storage(.hash(path)),
            priority: priority)
        guard case .storage(.hash(let bytes)) = response else {
            throw Error.unexpectedResponse(response)
        }
        return .init(bytes)
    }

    public func startRequest(
        _ name: String,
        args: String,
        priority: Priority?
    ) async throws {
        let response = try await session?.send(
            .application(.startRequest(name, args)),
            priority: priority)
        guard case .ok = response else {
            throw Error.unexpectedResponse(response)
        }
    }

    public func startStreaming(priority: Priority?) async throws {
        let response = try await session?.send(
            .gui(.screenStream(true)),
            priority: priority)
        guard case .ok = response else {
            throw Error.unexpectedResponse(response)
        }
    }

    public func stopStreaming(priority: Priority?) async throws {
        let response = try await session?.send(
            .gui(.screenStream(false)),
            priority: priority)
        guard case .ok = response else {
            throw Error.unexpectedResponse(response)
        }
    }

    public func onScreenFrame(_ body: @escaping (ScreenFrame) -> Void) {
        self.onScreenFrame = body
    }

    public func pressButton(
        _ button: InputKey,
        priority: Priority?
    ) async throws {
        func send(_ type: InputType) async throws -> Response? {
            try await session?.send(
                .gui(.button(button, type)),
                priority: priority)
        }
        guard try await send(.press) == .ok else {
            logger.error("sending press type failed")
            return
        }
        guard try await send(.short) == .ok else {
            logger.error("sending short type failed")
            return
        }
        guard try await send(.release) == .ok else {
            logger.error("sending release type failed")
            return
        }
    }

    public func playAlert(priority: Priority?) async throws {
        let response = try await session?.send(
            .system(.alert),
            priority: priority)
        guard case .ok = response else {
            throw Error.unexpectedResponse(response)
        }
    }

    public func startVirtualDisplay(
        with frame: ScreenFrame?, priority: Priority?
    ) async throws {
        let response = try await session?.send(
            .gui(.virtualDisplay(true, frame)),
            priority: priority)
        guard case .ok = response else {
            throw Error.unexpectedResponse(response)
        }
    }

    public func stopVirtualDisplay(priority: Priority?) async throws {
        let response = try await session?.send(
            .gui(.virtualDisplay(false, nil)),
            priority: priority)
        guard case .ok = response else {
            throw Error.unexpectedResponse(response)
        }
    }

    public func sendScreenFrame(
        _ frame: ScreenFrame,
        priority: Priority?
    ) async throws {
        try await session?.send(.screenFrame(frame), priority: priority)
    }
}
