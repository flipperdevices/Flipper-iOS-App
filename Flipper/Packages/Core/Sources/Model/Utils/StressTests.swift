import Peripheral

import Combine
import Foundation

// TODO: Refactor (ex StressTestViewModel)

@MainActor
public class StressTest: ObservableObject {
    private let pairedDevice: PairedDevice
    private let storage: StorageAPI
    private var cancellables: [AnyCancellable] = .init()

    var flipper: Flipper? {
        didSet {
            if let flipper = flipper {
                log(.info, "\(flipper.name) \(flipper.state)")
            }
        }
    }

    fileprivate let progressSubject = CurrentValueSubject<[Event], Never>([])

    public var progress: AnyPublisher<[Event], Never> {
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

    public init(pairedDevice: PairedDevice, storage: StorageAPI) {
        self.pairedDevice = pairedDevice
        self.storage = storage
        subscribeToPublishers()
    }

    func subscribeToPublishers() {
        pairedDevice.flipper
            .receive(on: DispatchQueue.main)
            .assign(to: \.flipper, on: self)
            .store(in: &cancellables)
    }

    var isRunning = false
    let temp = Path(string: "/ext/stress_test")

    public func start() {
        guard !isRunning else { return }
        isRunning = true

        progressSubject.value = []
        self.log(.info, "starting stress test")

        Task {
            try? await storage.delete(at: temp)

            let bytes: [UInt8] = .random(size: 1024)
            let path = temp

            while isRunning {
                do {
                    try await storage.write(at: path, bytes: bytes).drain()
                    log(.debug, "did write \(bytes.count) bytes at \(path)")
                } catch {
                    log(.error, "error wiring at \(path): \(error)")
                }

                guard isRunning else { return }

                do {
                    let received = try await storage.read(at: path).drain()
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
