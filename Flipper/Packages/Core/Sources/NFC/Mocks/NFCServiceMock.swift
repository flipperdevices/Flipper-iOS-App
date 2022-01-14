import Combine

public class NFCServiceMock: NFCService {
    public var items: SafePublisher<[ArchiveItem]> = .init(Just([]))

    public init() {
    }

    public func startReader() {
    }
}
