import Core
import Foundation
import AppIntents
import WidgetKit
import SwiftUI

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

    var emulating: String {
        get {
            UserDefaults.group.string(forKey: "emulating") ?? ""
        }
        nonmutating set {
            UserDefaults.group.set(newValue, forKey: "emulating")
            UserDefaults.group.synchronize()
        }
    }

    func perform() async throws -> some IntentResult {
        Task {
            let item = await Dependencies.shared.archiveModel.items.first {
                $0.path.string == entity.id
            }
            guard let item else {
                print("key not found")
                return
            }
            if emulating == item.path.string {
                try await stopEmulate()
                return
            }
            if !emulating.isEmpty {
                try await stopEmulate()
            }
            try await startEmulate(item)
        }
        return .result()
    }

    func startEmulate(_ item: ArchiveItem) async throws {
        emulating = item.path.string
        await Dependencies.shared.emulate.startEmulate(item)
    }

    func stopEmulate() async throws {
        emulating = ""
        await Dependencies.shared.emulate.stopEmulate()
    }
}

extension UserDefaults {
    static var group: UserDefaults {
        .init(suiteName: "group.com.flipperdevices.main")!
    }
}
