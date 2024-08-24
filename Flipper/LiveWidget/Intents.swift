import Foundation
import AppIntents
import WidgetKit

struct EmulateIntent: LiveActivityIntent {
    static var title: LocalizedStringResource { "Emulate Key" }

    @Parameter(title: "Archive Key")
    var entity: KeyEntity

    init() {
        entity = .invalid
    }

    init(entity: KeyEntity) {
        self.entity = entity
    }

    func perform() async throws -> Never {
        fatalError()
    }
}
