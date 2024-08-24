import SwiftUI
import WidgetKit

struct Provider: AppIntentTimelineProvider {
    var emulating: String {
        get {
            UserDefaults.group.string(forKey: "emulating") ?? ""
        }
        nonmutating set {
            UserDefaults.group.set(newValue, forKey: "emulating")
            UserDefaults.group.synchronize()
        }
    }

    func placeholder(in context: Context) -> Entry {
        Entry(
            date: Date(),
            isEmulating: false,
            configuration: ConfigurationAppIntent(entity: .invalid)
        )
    }

    func snapshot(
        for configuration: ConfigurationAppIntent,
        in context: Context
    ) async -> Entry {
        Entry(
            date: Date(),
            isEmulating: false,
            configuration: configuration
        )
    }

    func timeline(
        for configuration: ConfigurationAppIntent,
        in context: Context
    ) async -> Timeline<Entry> {
        .init(
            entries: [
                .init(
                    date: Date().addingTimeInterval(0),
                    isEmulating: emulating == configuration.entity.id,
                    configuration: configuration
                )
            ],
            policy: .never
        )
    }

    // func relevances() async -> WidgetRelevances<ConfigurationAppIntent> {
    //   // Generate a list containing the contexts this widget is relevant in.
    // }
}

extension UserDefaults {
    static var group: UserDefaults {
        .init(suiteName: "group.com.flipperdevices.main")!
    }
}
