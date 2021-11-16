import Injector
import Foundation

// swiftlint:disable multiline_arguments

public class RPCStressTest {
    static let shared: RPCStressTest = .init()

    @Inject var connector: BluetoothConnector
    var disposeBag: DisposeBag = .init()

    let rpc: RPC = .shared
    var flipper: BluetoothPeripheral? {
        didSet {
            switch flipper {
            case .some: sendEvent(.info, message: "device connected")
            case .none: sendEvent(.error, message: "device disconnected")
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
        self.sendEvent(.info, message: "starting stress test")

        testStorage()
    }

    public func stop() {
        guard isRunning else { return }
        isRunning = false

        self.sendEvent(.info, message: "stopping stress test")
    }

    func sendEvent(_ kind: Event.Kind, message: String) {
        progressSubject.value.append(.init(kind: kind, message: message))
    }

    var done = false
    let temp = Path(string: "/ext/stress_test")

    func testStorage() {
        rpc.deleteFile(at: temp) { _ in
            self.testStorageFile()
        }
    }

    func randomBuffer() -> [UInt8] {
        var bytes = [UInt8]()
        for _ in 0..<1024 {
            bytes.append(.random(in: (0 ..< UInt8.max)))
        }
        return bytes
    }

    func testStorageFile() {
        let bytes = randomBuffer()
        let path = temp
        rpc.writeFile(at: path, bytes: bytes, priority: .background) { result in
            switch result {
            case .success:
                self.sendEvent(.debug, message: "did write \(bytes.count) bytes at \(path)")
            case .failure(let error):
                self.sendEvent(.error, message: "error wiring at \(path): \(error)")
            }

            guard self.isRunning else {
                return
            }

            self.rpc.readFile(at: path, priority: .background) { result in
                switch result {
                case .success(let received):
                    self.sendEvent(.debug, message: "did read \(received.count) bytes from \(path)")
                    switch bytes == received {
                    case true: self.sendEvent(.success, message: "buffers are equal")
                    case false: self.sendEvent(.success, message: "buffers are NOT equal")
                    }
                case .failure(let error):
                    self.sendEvent(.error, message: "error reading from \(path): \(error)")
                }

                guard self.isRunning else {
                    return
                }

                self.testStorageFile()
            }
        }
    }
}
