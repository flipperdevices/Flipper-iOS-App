import Core
import Inject
import Peripheral
import Foundation
import Combine
import Logging

@MainActor
class RemoteContolViewModel: ObservableObject {
    private let logger = Logger(label: "remote")
    @Inject var rpc: RPC

    @Published var frame: ScreenFrame = .init()

    init() {
        rpc.onScreenFrame { [weak self] frame in
            guard let self = self else { return }
            Task { @MainActor in
                self.frame = frame
            }
        }
    }

    func startStreaming() {
        logger.info("start streaming")
        Task {
            do {
                try await rpc.startStreaming()
            } catch {
                logger.error("start streaming: \(error)")
            }
        }
    }

    func stopStreaming() {
        logger.info("stop streaming")
        Task {
            do {
                try await rpc.stopStreaming()
            } catch {
                logger.error("stop streaming: \(error)")
            }
        }
    }

    var isBusy = false

    func onButton(_ button: InputKey) {
        guard !isBusy else { return }
        isBusy = true
        logger.info("\(button) button pressed")
        feedback()
        Task {
            do {
                try await rpc.pressButton(button)
                isBusy = false
            } catch {
                logger.error("press button: \(error)")
            }
        }
    }
}
