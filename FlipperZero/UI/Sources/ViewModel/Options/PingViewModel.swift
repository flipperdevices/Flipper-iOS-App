import Core
import Combine
import Injector
import Foundation

@MainActor
class PingViewModel: ObservableObject {
    @Published var requestTimestamp: Int = .init()
    @Published var responseTimestamp: Int = .init()

    var ping: String {
        let result = responseTimestamp - requestTimestamp
        return result < 0 ? "" : String("\(result)ms")
    }

    var rpc: RPC = .shared

    var now: Int { .init(Date().timeIntervalSince1970 * 100) }

    init() {}

    func sendPing() async {
        do {
            requestTimestamp = now
            try await rpc.ping()
            responseTimestamp = now
        } catch {
            print(error)
        }
    }
}
