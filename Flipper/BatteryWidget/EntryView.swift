import SwiftUI

struct EntryView: View {
    @Environment(\.widgetFamily) private var widgetFamily

    let entry: Provider.Entry

    var body: some View {
        switch widgetFamily {
        case .accessoryCircular: BatteryViewCircular(entry: entry)
        case .accessoryInline: BatteryViewInline(entry: entry)
        case .accessoryRectangular: BatteryViewRectangular(entry: entry)
        default: EmptyView()
        }
    }
}
