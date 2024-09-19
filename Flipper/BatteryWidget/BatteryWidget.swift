import SwiftUI
import WidgetKit

struct BatteryWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: "BatteryWidget",
            provider: Provider()
        ) { entry in
            EntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Flipper Battery")
        .description("Displays battery status of your Flipper device")
        .supportedFamilies(
            [.accessoryInline, .accessoryCircular, .accessoryRectangular]
        )
    }
}
