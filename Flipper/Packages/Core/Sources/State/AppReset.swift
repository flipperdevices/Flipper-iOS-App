import Inject
import Darwin
import Logging

class AppReset {
    private let storage: FileStorage = .init()
    private let logger = Logger(label: "reset")

    func reset() {
        do {
            UserDefaultsStorage.shared.reset()
            try storage.reset()
            exit(0)
        } catch {
            logger.error("\(error)")
        }
    }
}
