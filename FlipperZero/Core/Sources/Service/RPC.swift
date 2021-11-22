import Injector

public class RPC {
    public static let shared: RPC = .init()

    var flipper: BluetoothPeripheral?

    @Inject var connector: BluetoothConnector
    var disposeBag: DisposeBag = .init()

    private init() {
        connector.connectedPeripherals
            .sink { [weak self] peripheral in
                self?.flipper = peripheral.first
            }
            .store(in: &disposeBag)
    }

    @discardableResult
    public func ping(_ bytes: [UInt8]) async throws -> [UInt8] {
        let response = try await flipper?.send(.ping(bytes))
        guard case .ping(let result) = response else {
            throw Error.unexpectedResponse(response)
        }
        return result
    }

    public func listDirectory(
        at path: Path,
        priority: Priority? = nil
    ) async throws -> [Element] {
        let response = try await flipper?.send(
            .list(path),
            priority: priority)
        guard case .list(let items) = response else {
            throw Error.unexpectedResponse(response)
        }
        return items
    }

    public func createFile(
        at path: Path,
        isDirectory: Bool,
        priority: Priority? = nil
    ) async throws {
        let response = try await flipper?.send(
            .create(path, isDirectory: isDirectory),
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
        let response = try await flipper?.send(
            .delete(path, isForce: force),
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
        let response = try await flipper?.send(
            .read(path),
            priority: priority)
        guard case .file(let bytes) = response else {
            throw Error.unexpectedResponse(response)
        }
        return bytes
    }

    public func writeFile(
        at path: Path,
        bytes: [UInt8],
        priority: Priority? = nil
    ) async throws {
        let response = try await flipper?.send(
            .write(path, bytes),
            priority: priority)
        guard case .ok = response else {
            throw Error.unexpectedResponse(response)
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
