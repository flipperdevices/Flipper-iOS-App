import Foundation
import Peripheral

@MainActor
public class StressTest: ObservableObject {
    private var pairedDevice: PairedDevice
    private var rpc: RPC { pairedDevice.session }
    private var disposeBag: DisposeBag = .init()

    var flipper: Flipper? {
        didSet {
            if let flipper = flipper {
                log(.info, "\(flipper.name) \(flipper.state)")
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

    public init(pairedDevice: PairedDevice) {
        self.pairedDevice = pairedDevice
        subscribeToPublishers()
    }

    func subscribeToPublishers() {
        pairedDevice.flipper
            .receive(on: DispatchQueue.main)
            .assign(to: \.flipper, on: self)
            .store(in: &disposeBag)
    }

    var isRunning = false
    let temp = Path(string: "/ext/stress_test")

    public func start() {
        guard !isRunning else { return }
        isRunning = true

        progressSubject.value = []
        self.log(.info, "starting stress test")

        Task {
            try? await rpc.deleteFile(at: temp)

            let bytes: [UInt8] = .random(size: 1024)
            let path = temp

            while isRunning {
                do {
                    try await rpc.writeFile(at: path, bytes: bytes)
                    log(.debug, "did write \(bytes.count) bytes at \(path)")
                } catch {
                    log(.error, "error wiring at \(path): \(error)")
                }

                guard isRunning else { return }

                do {
                    let received = try await rpc.readFile(at: path)
                    log(.debug, "did read \(received.count) bytes from \(path)")
                    switch bytes == received {
                    case true: log(.success, "buffers are equal")
                    case false: log(.error, "buffers are NOT equal")
                    }
                } catch {
                    log(.error, "error reading from \(path): \(error)")
                }
            }
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
}
