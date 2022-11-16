import Core
import Inject
import Combine
import Logging
import Peripheral
import Foundation

@MainActor
class PingViewModel: ObservableObject {
    private let logger = Logger(label: "ping")
    @Inject private var rpc: RPC

    @Published var payloadSize: Double = 1024
    @Published var requestTimestamp: Int = .init()
    @Published var responseTimestamp: Int = .init()

    var now: Int {
        .init(Date().timeIntervalSince1970 * 100)
    }

    var time: Int {
        guard responseTimestamp > requestTimestamp else { return 0 }
        return responseTimestamp - requestTimestamp
    }

    var bytesPerSecond: Int {
        guard time > 0 else { return 0 }
        return Int(Double(sent * 2) * (100.0 / Double(time)))
    }

    init() {}

    var sent: Int = 0

    func sendPing() {
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
