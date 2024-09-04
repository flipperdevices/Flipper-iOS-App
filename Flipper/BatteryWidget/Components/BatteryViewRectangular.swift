import WidgetKit
import SwiftUI

struct BatteryViewRectangular: View {
    let entry: Provider.Entry

    private var text: String {
        return switch entry.state {
        case .loading: "Loading Device"
        case .disconnected: "Disconnected"
        case .connected(let battery, _):
            "Flipper \(battery)%"
        }
    }

    var body: some View {
        Gauge(value: Double(entry.value), in: 0...100) {
            HStack {
                Spacer()

                Image(entry.image)
                    .resizable()
                    .frame(width: 40, height: 40)

                if entry.state == .loading {
                    Text(text)
                        .redacted(reason: .placeholder)
                } else {
                    Text(text)
                        .font(.system(size: 12, weight: .medium))
                }

                Spacer()
            }
        }
        .gaugeStyle(.accessoryLinearCapacity)
    }
}

#Preview("Rectangular Loading", as: .accessoryRectangular) {
    BatteryWidget()
} timeline: {
    Entry(
        date: .now,
        state: .loading
    )
}

#Preview("Rectangular Disconnected", as: .accessoryRectangular) {
    BatteryWidget()
} timeline: {
    Entry(
        date: .now,
        state: .disconnected
    )
}

#Preview("Rectangular Default", as: .accessoryRectangular) {
    BatteryWidget()
} timeline: {
    Entry(
        date: .now,
        state: .connected(65, false)
    )
}

#Preview("Rectangular Charging", as: .accessoryRectangular) {
    BatteryWidget()
} timeline: {
    Entry(
        date: .now,
        state: .connected(65, true)
    )
}
