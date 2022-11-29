import Inject
import Peripheral

import Logging
import Combine

public class FlipperService: ObservableObject {
    private let logger = Logger(label: "flipper-service")

    @Inject var rpc: RPC

    @Published public private(set) var frame: ScreenFrame = .init()

    public init() {
        subscribeToPublishers()
    }

    private func subscribeToPublishers() {
        rpc.onScreenFrame { [weak self] frame in
            guard let self else { return }
            Task { @MainActor in
                self.frame = frame
            }
        }
    }

    public func startScreenStreaming() {
        Task {
            do {
                try await rpc.startStreaming()
            } catch {
                logger.error("start streaming: \(error)")
            }
        }
    }

    public func stopScreenStreaming() {
        Task {
            do {
                try await rpc.stopStreaming()
            } catch {
                logger.error("stop streaming: \(error)")
            }
        }
    }

    public func pressButton(_ button: InputKey) {
        Task {
            do {
                try await rpc.pressButton(button)
            } catch {
                logger.error("press button: \(error)")
            }
        }
    }

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
