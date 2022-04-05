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
        rpc.onScreenFrame { [weak self] in
            self?.frame = $0
        }
    }

    func startStreaming() {
        logger.info("start streaming")
        Task {
            try await rpc.startStreaming()
        }
    }

    func stopStreaming() {
        logger.info("stop streaming")
        Task {
            try await rpc.stopStreaming()
        }
    }

    var isBusy = false

    func onButton(_ button: InputKey) {
        guard !isBusy else { return }
        isBusy = true
        logger.info("\(button) button pressed")
        feedback()
        Task {
            try await rpc.pressButton(button)
            isBusy = false
        }
    }
}

import SwiftUI

func feedback() {
    let impactMed = UIImpactFeedbackGenerator(style: .heavy)
    impactMed.impactOccurred()
}
