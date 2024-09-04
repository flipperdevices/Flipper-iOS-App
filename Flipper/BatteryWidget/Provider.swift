import SwiftUI
import WidgetKit

struct Provider: TimelineProvider {

    func placeholder(in context: Context) -> Entry {
        .init(
            date: .now,
            state: .loading)
    }

    func getSnapshot(
        in context: Context,
        completion: @escaping (Entry) -> Void
    ) {
        completion(
            .init(
                date: .now,
                state: getState())
        )
    }

    func getTimeline(
        in context: Context,
        completion: @escaping (Timeline<Entry>) -> Void
    ) {
        completion(
            .init(
                entries: [
                    .init(
                        date: Date().addingTimeInterval(0),
                        state: getState())
                ],
                policy: .never
            )
        )
    }

    private func getState() -> Entry.State {
        let battery = UserDefaults.group.integer(forKey: "battery_level")

        if battery == -1 {
            return .disconnected
        }

        let isCharging =  UserDefaults.group.bool(forKey: "battery_charging")
        return .connected(battery, isCharging)
    }
}

extension UserDefaults {
    static var group: UserDefaults {
        .init(suiteName: "group.com.flipperdevices.main")!
    }
}
