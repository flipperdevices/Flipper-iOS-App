import Inject

public class RPC {
    public static let shared: RPC = .init()

    private var session: Session?

    @Inject var connector: BluetoothConnector
    var disposeBag: DisposeBag = .init()

    public var onScreenFrame: ((ScreenFrame) -> Void)? {
        get { session?.onScreenFrame }
        set { session?.onScreenFrame = newValue }
    }

    private init() {
        connector.connectedPeripherals
            .sink { [weak self] peripherals in
                guard let peripheral = peripherals.first else {
                    self?.session = nil
                    return
                }
                self?.session = FlipperSession(peripheral: peripheral)
            }
            .store(in: &disposeBag)
    }

    @discardableResult
    public func ping(_ bytes: [UInt8]) async throws -> [UInt8] {
        let response = try await session?.send(.system(.ping(bytes)))
        guard case .system(.ping(let result)) = response else {
            throw Error.unexpectedResponse(response)
        }
        return result
    }

    public func listDirectory(
        at path: Path,
        priority: Priority? = nil
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
        priority: Priority? = nil
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
        force: Bool = false,
        priority: Priority? = nil
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
        priority: Priority? = nil
    ) async throws {
        let response = try await session?.send(
            .storage(.write(path, bytes)),
            priority: priority)
        guard case .ok = response else {
            throw Error.unexpectedResponse(response)
        }
    }

    public func calculateFileHash(
        at path: Path,
        priority: Priority? = nil
    ) async throws -> String {
        let response = try await session?.send(
            .storage(.hash(path)),
            priority: priority)
        guard case .storage(.hash(let bytes)) = response else {
            throw Error.unexpectedResponse(response)
        }
        return bytes
    }

    public func startStreaming() async throws {
        let response = try await session?.send(.gui(.remote(true)))
        guard case .ok = response else {
            throw Error.unexpectedResponse(response)
        }
    }

    public func stopStreaming() async throws {
        let response = try await session?.send(.gui(.remote(false)))
        guard case .ok = response else {
            throw Error.unexpectedResponse(response)
        }
    }

    public func pressButton(_ button: InputKey) async throws {
        func inputType(_ type: InputType) -> Request {
            .gui(.button(button, type))
        }
        guard try await session?.send(inputType(.press)) == .ok else {
            print("press failed")
            return
        }
        guard try await session?.send(inputType(.short)) == .ok else {
            print("short failed")
            return
        }
        guard try await session?.send(inputType(.release)) == .ok else {
            print("release failed")
            return
        }
    }
}

extension RPC {
    public func writeFile(
        at path: Path,
        string: String,
        priority: Priority? = nil
    ) async throws {
        try await writeFile(
            at: path,
            bytes: .init(string.utf8),
            priority: priority)
    }
}
