public protocol DesktopAPI {
    var isLocked: Bool { get async throws }

    func unlock() async throws
}
