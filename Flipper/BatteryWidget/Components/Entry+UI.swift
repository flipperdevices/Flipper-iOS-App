import SwiftUI
import WidgetKit

struct BatteryGaugeView: View {
    let entry: Provider.Entry

    var body: some View {
        Gauge(value: Double(entry.value), in: 0...100) {
            Image(entry.image)
                .resizable()
                .frame(width: 40, height: 40)
        }
    }
}

extension Entry {
    var image: String {
        return switch self.state {
        case .loading: "FlipperUnknown"
        case .disconnected: "FlipperDisconnected"
        case .connected(_, let isCharging):
            isCharging ? "FlipperCharging" : "Flipper"
        }
    }

    var value: Int {
        return switch self.state {
        case .connected(let battery, _): battery
        default: 0
        }
    }
}
