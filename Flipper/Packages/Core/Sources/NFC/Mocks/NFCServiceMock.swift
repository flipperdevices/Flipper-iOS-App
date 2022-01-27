import Combine

public class NFCServiceMock: NFCService {
    public var items: SafePublisher<[ArchiveItem]> = .init(Empty())

    public init() {
    }

    public func startReader() {
    }
}
