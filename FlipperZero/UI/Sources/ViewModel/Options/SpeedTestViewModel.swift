import Core
import Combine
import Injector
import struct Foundation.Date
import struct Foundation.UUID

class SpeedTestViewModel: ObservableObject {
    @Inject var connector: BluetoothConnector

    static let defaultPacketSize = 38
    static let maximumPacketSize = 256
    private var bytes = [UInt8](repeating: 42, count: defaultPacketSize)

    @Published var packetSize: Int = defaultPacketSize {
        didSet {
            bytes = .init(repeating: 42, count: packetSize)
        }
    }

    @Published private(set) var isRunning = false
    @Published var received: Int = 0
    @Published var rps: Int = 0
    private var disposeBag: DisposeBag = .init()

    private var startTime: Date = .init()
    private var lastTime: Date = .init()

    private func record(_ byteCount: Int) {
        received += byteCount
        let timeInterval = Date().timeIntervalSince(lastTime)
        rps = Int(Double(byteCount) * (1.0 / timeInterval))
        received = 0
        lastTime = Date()
    }

    var deviceUUID: UUID?

    init() {
        connector.connectedPeripherals
            .sink { [weak self] in
                self?.deviceUUID = $0.first?.id
            }
            .store(in: &disposeBag)

        connector.received
            .sink { [weak self] in
                guard let self = self else { return }
                self.record($0.count)
                if self.isRunning, let identifier = self.deviceUUID {
                    self.connector.send(self.bytes, to: identifier)
                }
            }
            .store(in: &disposeBag)
    }

    func start() {
        guard let identifier = deviceUUID else {
            return
        }
        isRunning = true
        startTime = Date()
        lastTime = Date()
        self.connector.send(bytes, to: identifier)
    }

    func stop() {
        isRunning = false
    }
}
