import Peripheral

import Combine
import Foundation

// TODO: Refactor (ex SpeedTestViewModel)

@MainActor
public class SpeedTest: ObservableObject {
    private let system: SystemAPI

    public init(system: SystemAPI) {
        self.system = system
    }

    public let defaultPacketSize = 400
    public let maximumPacketSize = 1024

    @Published public var packetSize: Double = 400.0
    @Published public private(set) var isRunning = false
    @Published public var bps: Int = 0 {
        willSet {
            bpsMin = bpsMin == 0 ? bps : min(bpsMin, newValue)
            bpsMax = bpsMax == 0 ? bps : max(bpsMax, newValue)
        }
    }
    @Published public var bpsMin: Int = 0
    @Published public var bpsMax: Int = 0

    @Published public var totalBPS: Int = 0

    public func runSpeedTest() async throws {
        let start = Date()
        var bytesTransfered: Int = 0
        while isRunning {
            do {
                let sent = [UInt8].random(size: Int(packetSize))

                let currentStart = Date()
                let received = try await system.ping(sent)
                let time = Date().timeIntervalSince(currentStart)
                bps = Int(Double(sent.count + received.count) * (1.0 / time))

                bytesTransfered += sent.count + received.count
                let totalTime = Date().timeIntervalSince(start)
                totalBPS = Int(Double(bytesTransfered) * (1.0 / totalTime))

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
