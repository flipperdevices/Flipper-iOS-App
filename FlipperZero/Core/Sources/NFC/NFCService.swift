public protocol NFCService {
    var items: SafePublisher<[ArchiveItem]> { get }

    func startReader()
}
