import Combine
import Network

public class NetworkService: ObservableObject {
    @Published public private(set) var available: Bool = false

    public init() {
        monitorNetworkStatus()
    }

    func monitorNetworkStatus() {
        let monitor = NWPathMonitor()
        var lastStatus: NWPath.Status?
        monitor.pathUpdateHandler = { [weak self] path in
            guard lastStatus != path.status else { return }
            self?.onNetworkStatusChanged(path.status)
            lastStatus = path.status
        }
        monitor.start(queue: .main)
    }

    func onNetworkStatusChanged(_ status: NWPath.Status) {
        available = status != .unsatisfied
    }
}
