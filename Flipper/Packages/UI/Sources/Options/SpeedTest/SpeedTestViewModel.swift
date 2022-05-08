import Core
import Inject
import Combine
import Logging
import Peripheral
import struct Foundation.Date

@MainActor
class SpeedTestViewModel: ObservableObject {
    private let logger = Logger(label: "speedtest")
    @Inject var rpc: RPC

    let defaultPacketSize = 444
    let maximumPacketSize = 1024

    @Published var packetSize: Double = 444.0
    @Published private(set) var isRunning = false
    @Published var bps: Int = 0 {
        willSet {
            bpsMin = bpsMin == 0 ? bps : min(bpsMin, newValue)
            bpsMax = bpsMax == 0 ? bps : max(bpsMax, newValue)
        }
    }
    @Published var bpsMin: Int = 0
    @Published var bpsMax: Int = 0
    private var disposeBag: DisposeBag = .init()

    init() {}

    func runSpeedTest() async throws {
        while isRunning {
            do {
                let sent = [UInt8].random(size: Int(packetSize))

                let start = Date()
                let received = try await rpc.ping(sent)
                let time = Date().timeIntervalSince(start)
                bps = Int(Double(sent.count + received.count) * (1.0 / time))

                guard sent == received else {
                    logger.error("buffers are not equal")
                    return
                }
            } catch {
                logger.critical("\(error)")
                try await Task.sleep(nanoseconds: 1_000_000)
            }
        }
    }

    func start() {
        guard !isRunning else { return }
        isRunning = true
        Task {
            do {
                try await runSpeedTest()
            } catch {
                logger.error("speed test: \(error)")
            }
        }
    }

    func stop() {
        guard isRunning else { return }
        isRunning = false
    }
}
