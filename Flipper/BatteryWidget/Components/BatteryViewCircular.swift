import SwiftUI
import WidgetKit

struct BatteryViewCircular: View {
    let entry: Provider.Entry

    var body: some View {
        Gauge(value: Double(entry.value), in: 0...100) {
            Image(entry.image)
                .resizable()
                .frame(width: 40, height: 40)
        }
        .gaugeStyle(.accessoryCircularCapacity)
    }
}

#Preview("Circular Loading", as: .accessoryCircular) {
    BatteryWidget()
} timeline: {
    Entry(
        date: .now,
        state: .loading
    )
}

#Preview("Circular Disconnected", as: .accessoryCircular) {
    BatteryWidget()
} timeline: {
    Entry(
        date: .now,
        state: .disconnected
    )
}

#Preview("Circular Default", as: .accessoryCircular) {
    BatteryWidget()
} timeline: {
    Entry(
        date: .now,
        state: .connected(65, false)
    )
}

#Preview("Circular Charging", as: .accessoryCircular) {
    BatteryWidget()
} timeline: {
    Entry(
        date: .now,
        state: .connected(65, true)
    )
}
