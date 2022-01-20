import Core
import Inject
import Combine
import Foundation

@MainActor
class NamedLogsViewModel: ObservableObject {
    @Inject private var loggerStorage: LoggerStorage

    let name: String

    @Published var messages: [String] = []

    init(name: String) {
        self.name = name
        self.messages = loggerStorage.read(name)
    }
}
