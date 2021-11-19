import Injector
import Foundation

// swiftlint:disable nesting

public class RPCStressTest {
    static let shared: RPCStressTest = .init()

    @Inject var connector: BluetoothConnector
    var disposeBag: DisposeBag = .init()

    let rpc: RPC = .shared
    var flipper: BluetoothPeripheral? {
        didSet {
            switch flipper {
            case .some: log(.info, "device connected")
            case .none: log(.error, "device disconnected")
            }
        }
    }

    fileprivate let progressSubject = SafeValueSubject<[Event]>([])

    public var progress: SafePublisher<[Event]> {
        progressSubject.eraseToAnyPublisher()
    }

    public struct Event: Identifiable {
        public let id: UUID = .init()
        public let kind: Kind
        public let message: String

        public enum Kind {
            case info
            case debug
            case error
            case success
        }
    }

    public init() {
        connector.connectedPeripherals
            .sink { [weak self] in
                self?.flipper = $0.first
            }
            .store(in: &disposeBag)
    }

    var isRunning = false

    public func start() {
        guard !isRunning else { return }
        isRunning = true

        progressSubject.value = []
        self.log(.info, "starting stress test")

        Task {
            await testStorage()
        }
    }

    public func stop() {
        guard isRunning else { return }
        isRunning = false

        self.log(.info, "stopping stress test")
    }

    func log(_ kind: Event.Kind, _ message: String) {
        progressSubject.value.append(.init(kind: kind, message: message))
    }

    var done = false
    let temp = Path(string: "/ext/stress_test")

    func testStorage() async {
        try? await rpc.deleteFile(at: temp)
        await testStorageFile()
    }

    func randomBuffer() -> [UInt8] {
        var bytes = [UInt8]()
        for _ in 0..<1024 {
            bytes.append(.random(in: (0 ..< UInt8.max)))
        }
        return bytes
    }

    func testStorageFile() async {
        let bytes = randomBuffer()
        let path = temp

        do {
            try await rpc.writeFile(at: path, bytes: bytes, priority: .background)
            log(.success, "did write \(bytes.count) bytes at \(path)")
        } catch {
            log(.error, "error wiring at \(path): \(error)")
        }

        guard isRunning else { return }

        do {
            let received = try await rpc.readFile(at: path, priority: .background)
            log(.debug, "did read \(received.count) bytes from \(path)")
            switch bytes == received {
            case true: log(.success, "buffers are equal")
            case false: log(.error, "buffers are NOT equal")
            }
        } catch {
            log(.error, "error reading from \(path): \(error)")
        }

        guard self.isRunning else { return }

        Task {
            await testStorageFile()
        }
    }
}
