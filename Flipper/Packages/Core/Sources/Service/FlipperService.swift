import Inject
import Peripheral
import Combine
import Logging

public class FlipperService: ObservableObject {
    private let logger = Logger(label: "device-service")

    @Inject var rpc: RPC

    public init() {}

    public func playAlert() {
        Task {
            do {
                try await rpc.playAlert()
            } catch {
                logger.error("play alert intent: \(error)")
            }
        }
    }

    public func reboot() {
        Task {
            do {
                try await rpc.reboot(to: .os)
            } catch {
                logger.error("reboot flipper: \(error)")
            }
        }
    }
}
