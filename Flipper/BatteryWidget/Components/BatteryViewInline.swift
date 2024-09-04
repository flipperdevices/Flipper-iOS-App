import WidgetKit
import SwiftUI

struct BatteryViewInline: View {
    let entry: Provider.Entry

    var body: some View {
        switch entry.state {
        case .loading:
            Text("Loading Device")
                .redacted(reason: .placeholder)
        case .disconnected:
            Text("Flipper Disconnected")
                .font(.system(size: 12, weight: .medium))
        case .connected(let battery, let isCharging):
            HStack {
                if isCharging {
                    Image("Charging")
                        .resizable()
                        .frame(width: 24, height: 24)
                }

                Text("Flipper \(battery)%")
                    .font(.system(size: 12, weight: .medium))
            }
        }
    }
}

#Preview("Inline Loading", as: .accessoryInline) {
    BatteryWidget()
} timeline: {
    Entry(
        date: .now,
        state: .loading
    )
}

#Preview("Inline Disconnected", as: .accessoryInline) {
    BatteryWidget()
} timeline: {
    Entry(
        date: .now,
        state: .disconnected
    )
}

#Preview("Inline Default", as: .accessoryInline) {
    BatteryWidget()
} timeline: {
    Entry(
        date: .now,
        state: .connected(65, false)
    )
}

#Preview("Inline Charging", as: .accessoryInline) {
    BatteryWidget()
} timeline: {
    Entry(
        date: .now,
        state: .connected(65, true)
    )
}
