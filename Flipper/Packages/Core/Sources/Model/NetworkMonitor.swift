import Combine
import Network

public class NetworkMonitor: ObservableObject {
    @Published public private(set) var isAvailable = false

    private var oldValue: NWPath.Status?

    public init() {
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self else { return }
            guard self.oldValue != path.status else { return }
            self.isAvailable = path.status != .unsatisfied
            self.oldValue = path.status
        }
        monitor.start(queue: .main)
    }
}
