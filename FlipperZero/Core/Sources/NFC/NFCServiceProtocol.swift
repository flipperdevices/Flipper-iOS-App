public protocol NFCServiceProtocol {
    var items: SafePublisher<[ArchiveItem]> { get }

    func startReader()
}
