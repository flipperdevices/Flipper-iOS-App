import Inject
import Logging
import Foundation
import Peripheral

@MainActor
public class SpeedTest: ObservableObject {
    @Inject private var pairedDevice: PairedDevice
    private var rpc: RPC { pairedDevice.session }

    public let defaultPacketSize = 444
    public let maximumPacketSize = 1024

    @Published public var packetSize: Double = 444.0
    @Published public private(set) var isRunning = false
    @Published public var bps: Int = 0 {
        willSet {
            bpsMin = bpsMin == 0 ? bps : min(bpsMin, newValue)
            bpsMax = bpsMax == 0 ? bps : max(bpsMax, newValue)
        }
    }
    @Published public var bpsMin: Int = 0
    @Published public var bpsMax: Int = 0

    public init() {}

    public func runSpeedTest() async throws {
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

    public func start() {
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

    public func stop() {
        guard isRunning else { return }
        isRunning = false
    }
}
