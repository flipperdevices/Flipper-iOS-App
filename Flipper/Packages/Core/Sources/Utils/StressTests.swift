import Inject
import Foundation
import Peripheral

// swiftlint:disable nesting

public class StressTest {
    static let shared: StressTest = .init()
    private let rpc: RPC = .shared

    @Inject var connector: BluetoothConnector
    var disposeBag: DisposeBag = .init()

    var peripheral: BluetoothPeripheral? {
        didSet {
            switch peripheral {
            case .some(let peripheral):
                log(.info, "device \(peripheral.state)")
            case .none:
                log(.error, "device disconnected")
                stop()
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
        connector.connected
            .map { $0.first }
            .assign(to: \.peripheral, on: self)
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

    func testStorageFile() async {
        let bytes: [UInt8] = .random(size: 1024)
        let path = temp

        do {
            try await rpc.writeFile(at: path, bytes: bytes, priority: .background)
            log(.debug, "did write \(bytes.count) bytes at \(path)")
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
