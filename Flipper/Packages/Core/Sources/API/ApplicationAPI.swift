import Peripheral

public protocol ApplicationAPI {
    var state: AsyncStream<IncomingMessage.AppState> { get async }

    var isLocked: Bool { get async throws }

    func start(_ name: String, args: String) async throws
    func loadFile(_ path: Path) async throws
    func buttonPress(args: String, index: Int) async throws
    func buttonRelease() async throws
    func exit() async throws
}

extension ApplicationAPI {
    func buttonPress(index: Int = 0) async throws {
        try await buttonPress(args: "", index: index)
    }
}
