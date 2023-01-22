import Inject
import Peripheral

import Combine
import Logging
import Foundation

// TODO: Refactor (ex PingViewModel)

@MainActor
public class PingTest: ObservableObject {
    @Inject private var pairedDevice: PairedDevice
    private var rpc: RPC { pairedDevice.session }

    @Published public var payloadSize: Double = 1024
    @Published public var requestTimestamp: Int = .init()
    @Published public var responseTimestamp: Int = .init()

    public var time: Int {
        guard responseTimestamp > requestTimestamp else { return 0 }
        return responseTimestamp - requestTimestamp
    }

    public var bytesPerSecond: Int {
        guard time > 0 else { return 0 }
        return Int(Double(sent * 2) * (100.0 / Double(time)))
    }

    public init() {}

    var sent: Int = 0

    var now: Int {
        .init(Date().timeIntervalSince1970 * 100)
    }

    public func sendPing() {
        Task {
            do {
                sent = Int(payloadSize)
                requestTimestamp = now
                let sent: [UInt8] = .random(size: sent)
                let received = try await rpc.ping(sent)
                responseTimestamp = now

                if received != sent {
                    logger.error("buffers are not equal")
                }
            } catch {
                logger.error("\(error)")
            }
        }
    }
}
