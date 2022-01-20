import Core
import Combine
import Foundation

@MainActor
class StressTestViewModel: ObservableObject {
    var stressTest: StressTest = .init()
    var disposeBag: DisposeBag = .init()

    @Published var events: [StressTest.Event] = []

    var successCount: Int {
        events.filter { $0.kind == .success }.count
    }

    var errorCount: Int {
        events.filter { $0.kind == .error }.count
    }

    init() {
        stressTest.progress
            .receive(on: DispatchQueue.main)
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

extension StressTest.Event: CustomStringConvertible {
    public var description: String {
        "[\(self.kind)] \(self.message)"
    }
}
