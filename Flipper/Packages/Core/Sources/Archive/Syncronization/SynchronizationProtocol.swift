protocol SynchronizationProtocol {
    func syncWithDevice() async throws
    func reset()
}
