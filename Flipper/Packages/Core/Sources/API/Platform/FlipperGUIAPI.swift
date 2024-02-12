import Peripheral

import Foundation

class FlipperGUIAPI: GUIAPI {
    private var rpc: Session { pairedDevice.session }
    private let pairedDevice: PairedDevice

    init(pairedDevice: PairedDevice) {
        self.pairedDevice = pairedDevice
    }

    var screenFrame: AsyncStream<ScreenFrame> {
        rpc.message.compactMap { message in
            switch message {
            case .screenFrame(let frame):
                return frame
            default:
                return nil
            }
        }
    }

    func startStreaming() async throws {
        try await rpc.startStreaming()
    }

    func stopStreaming() async throws {
        try await rpc.stopStreaming()
    }

    func pressButton(_ button: InputKey, isLong: Bool) async throws {
        try await rpc.pressButton(button, isLong: isLong)
    }

    func playAlert() async throws {
        try await rpc.playAlert()
    }

    func startVirtualDisplay(with frame: ScreenFrame?) async throws {
        try await rpc.startVirtualDisplay(with: frame)
    }

    func stopVirtualDisplay() async throws {
        try await rpc.stopVirtualDisplay()
    }

    func sendScreenFrame(_ frame: ScreenFrame) async throws {
        try await rpc.sendScreenFrame(frame)
    }
}
