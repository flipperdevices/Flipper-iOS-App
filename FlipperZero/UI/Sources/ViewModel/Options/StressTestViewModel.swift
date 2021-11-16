import Core
import Combine
import Injector
import Foundation

class StressTestViewModel: ObservableObject {
    var stressTest: RPCStressTest = .init()
    var disposeBag: DisposeBag = .init()

    @Published var events: [RPCStressTest.Event] = []

    var successCount: Int {
        events.filter { $0.kind == .success }.count
    }

    var errorCount: Int {
        events.filter { $0.kind == .error }.count
    }

    init() {
        stressTest.progress
            .sink { [weak self] in
                self?.events = $0
            }
            .store(in: &disposeBag)
    }

    func start() {
        stressTest.start()
    }

    func stop() {
        stressTest.stop()
    }
}

extension RPCStressTest.Event: CustomStringConvertible {
    public var description: String {
        "[\(self.kind)] \(self.message)"
    }
}
