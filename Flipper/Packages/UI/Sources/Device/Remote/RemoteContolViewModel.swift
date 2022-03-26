import Core
import Combine
import Bluetooth
import Foundation
import Logging

@MainActor
class RemoteContolViewModel: ObservableObject {
    private let logger = Logger(label: "remote")
    private let rpc: RPC = .shared

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

    func onButton(_ button: InputKey) {
        logger.info("\(button) button pressed")
        feedback()
        Task {
            try await rpc.pressButton(button)
        }
    }
}

import SwiftUI

func feedback() {
    let impactMed = UIImpactFeedbackGenerator(style: .medium)
    impactMed.impactOccurred()
}
