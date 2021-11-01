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

    public func listDirectory(
        at path: Path,
        _ completion: @escaping (Result<[Element], Error>) -> Void
    ) {
        flipper?.send(.list(path)) { result in
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
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        flipper?.send(.create(path, isDirectory: isDirectory)) { result in
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
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        flipper?.send(.delete(path, isForce: force)) { result in
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
        completion: @escaping (Result<[UInt8], Error>) -> Void
    ) {
        flipper?.send(.read(path)) { result in
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
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        flipper?.send(.write(path, bytes)) { result in
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
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        writeFile(
            at: path,
            bytes: .init(string.utf8),
            completion: completion)
    }
}
