import Peripheral

public protocol GUIAPI {
    var screenFrame: AsyncStream<ScreenFrame> { get async }

    func startStreaming() async throws
    func stopStreaming() async throws
    func pressButton(_ button: InputKey, isLong: Bool) async throws
    func playAlert() async throws
    func startVirtualDisplay(with frame: ScreenFrame?) async throws
    func stopVirtualDisplay() async throws
    func sendScreenFrame(_ frame: ScreenFrame) async throws
}
