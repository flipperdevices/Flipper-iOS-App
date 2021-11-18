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

    public func ping() async throws {
        return try await withCheckedThrowingContinuation { continuation in
            flipper?.send(.ping) { result in
                switch result {
                case .success(.ping):
                    continuation.resume()
                case .failure(let error):
                    continuation.resume(throwing: error)
                default:
                    continuation.resume(throwing: Error.common(.unknown))
                }
            }
        }
    }

    public func listDirectory(
        at path: Path,
        priority: Priority? = nil,
        _ completion: @escaping (Result<[Element], Error>) -> Void
    ) {
        flipper?.send(.list(path), priority: priority) { result in
            switch result {
            case .success(.list(let items)):
                completion(.success(items))
            case .failure(let error):
                completion(.failure(error))
            default:
                completion(.failure(.common(.unknown)))
            }
        }
    }

    public func createFile(
        at path: Path,
        isDirectory: Bool,
        priority: Priority? = nil,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        flipper?.send(
            .create(path, isDirectory: isDirectory),
            priority: priority
        ) { result in
            switch result {
            case .success(.ok):
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            default:
                completion(.failure(.common(.unknown)))
            }
        }
    }

    public func deleteFile(
        at path: Path,
        force: Bool = false,
        priority: Priority? = nil,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        flipper?.send(
            .delete(path, isForce: force),
            priority: priority
        ) { result in
            switch result {
            case .success(.ok):
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            default:
                completion(.failure(.common(.unknown)))
            }
        }
    }

    public func readFile(
        at path: Path,
        priority: Priority? = nil,
        completion: @escaping (Result<[UInt8], Error>) -> Void
    ) {
        flipper?.send(.read(path), priority: priority) { result in
            switch result {
            case .success(.file(let bytes)):
                completion(.success(bytes))
            case .failure(let error):
                completion(.failure(error))
            default:
                completion(.failure(.common(.unknown)))
            }
        }
    }

    public func writeFile(
        at path: Path,
        bytes: [UInt8],
        priority: Priority? = nil,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        flipper?.send(.write(path, bytes), priority: priority) { result in
            switch result {
            case .success(.ok):
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            default:
                completion(.failure(.common(.unknown)))
            }
        }
    }
}

extension RPC {
    public func writeFile(
        at path: Path,
        string: String,
        priority: Priority? = nil,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        writeFile(
            at: path,
            bytes: .init(string.utf8),
            priority: priority,
            completion: completion)
    }
}
