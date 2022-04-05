import Inject
import Combine
import Logging
import struct Foundation.Date

public class BluetoothRPC: RPC {
    private let logger = Logger(label: "rpc")

    @Inject private var connector: BluetoothConnector
    private var subscriptions = [AnyCancellable]()

    private var session: Session?
    private var peripheral: BluetoothPeripheral? {
        didSet { self.updateSession() }
    }
    private var onScreenFrame: ((ScreenFrame) -> Void)?

    init() {
        connector.connected
            .map { $0.first }
            .assign(to: \.peripheral, on: self)
            .store(in: &subscriptions)
    }

    private func updateSession() {
        guard let peripheral = peripheral else {
            self.session = nil
            return
        }
        self.session = FlipperSession(peripheral: peripheral)
        self.session?.onMessage = self.onMessage
    }

    private func onMessage(_ message: Message) {
        switch message {
        case .decodeError:
            onDecodeError()
        case .screenFrame(let screenFrame):
            onScreenFrame?(screenFrame)
        }
    }

    private func onDecodeError() {
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
        to mode: Request.System.RebootMode,
        priority: Priority?
    ) async throws {
        _ = try await session?.send(.system(.reboot(mode)), priority: priority)
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

    public func startVirtualDisplay(priority: Priority?) async throws {
        let response = try await session?.send(
            .gui(.virtualDisplay(true)),
            priority: priority)
        guard case .ok = response else {
            throw Error.unexpectedResponse(response)
        }
    }

    public func stopVirtualDisplay(priority: Priority?) async throws {
        let response = try await session?.send(
            .gui(.virtualDisplay(false)),
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
