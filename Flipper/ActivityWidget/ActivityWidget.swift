import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> Entry {
        Entry(date: Date(), configuration: ConfigurationIntent())
    }

    func getSnapshot(
        for configuration: ConfigurationIntent,
        in context: Context,
        completion: @escaping (Entry) -> Void
    ) {
        let entry = Entry(date: Date(), configuration: configuration)
        completion(entry)
    }

    func getTimeline(
        for configuration: ConfigurationIntent,
        in context: Context,
        completion: @escaping (Timeline<Entry>) -> Void
    ) {
        var entries: [Entry] = []

        // Generate a timeline consisting of five entries an hour apart,
        // starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(
                byAdding: .hour,
                value: hourOffset,
                to: currentDate)!
            let entry = Entry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct Entry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
}

struct ActivityWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        Text(entry.date, style: .time)
    }
}

struct ActivityWidget: Widget {
    let kind: String = "ActivityWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(
            kind: kind,
            intent: ConfigurationIntent.self,
            provider: Provider()
        ) { entry in
            ActivityWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct ActivityWidget_Previews: PreviewProvider {
    static var previews: some View {
        ActivityWidgetEntryView(
            entry: Entry(
                date: Date(),
                configuration: ConfigurationIntent())
        )
        .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
