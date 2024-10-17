import Core
import Peripheral
import SwiftUI

struct SyncProgress: View {
    let progress: Synchronization.Progress

    private var gaugeValue: Double {
        Double(progress.value)
    }

    private var description: String {
        return switch progress {
        case .prepare: "Preparing syncing with Flipper..."
        case .syncManifest: "Getting files from Flipper..."
        case .syncFile(_, let file): "Syncing: \(file)"
        case .done: "Done!"
        }
    }

    init(_ progress: Synchronization.Progress) {
        self.progress = progress
    }

    var body: some View {
        VStack(spacing: 12) {
            Text("Syncing")
                .font(.system(size: 18, weight: .bold))

            Gauge(value: gaugeValue, in: 0...100) {
            } currentValueLabel: {
                Text("\(progress.value)%")
                    .font(.system(size: 14, weight: .medium))
            }
            .gaugeStyle(.accessoryCircularCapacity)
            .tint(.a2)
            .animation(.easeInOut(duration: 0.05), value: gaugeValue)

            Text(description)
                .font(.system(size: 14, weight: .medium))
                .animation(.easeInOut(duration: 0.05), value: description)
        }
    }
}

#Preview("Prepare") {
    SyncProgress(.prepare)
}

#Preview("Sync Manifest") {
    SyncProgress(.syncManifest(0.34))
}

#Preview("Sync File") {
    SyncProgress(.syncFile(0.67, ".mfkey32.log"))
}

#Preview("Done") {
    SyncProgress(.done)
}
