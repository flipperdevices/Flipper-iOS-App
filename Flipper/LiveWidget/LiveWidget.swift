import WidgetKit
import SwiftUI

struct LiveWidget: Widget {
    let kind: String = "LiveWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: ConfigurationAppIntent.self,
            provider: Provider()
        ) { entry in
            EntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemSmall) {
    LiveWidget()
} timeline: {
    Entry(
        date: .now,
        isEmulating: true,
        configuration: .cyfral
    )
    Entry(
        date: .now,
        isEmulating: false,
        configuration: .garage
    )
}

extension ConfigurationAppIntent {
    fileprivate static var cyfral: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent(
            entity: .init(id: "", name: "Cyfral", kind: .ibutton)
        )
        return intent
    }

    fileprivate static var garage: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent(
            entity: .init(id: "", name: "Garage", kind: .subghz)
        )
        return intent
    }
}
