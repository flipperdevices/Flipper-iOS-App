import Core
import SwiftUI

struct ErrorView: View {
    let error: WidgetService.State.Error
    let onBack: () -> Void

    var body: some View {
        Group {
            switch error {
            case .appLocked:
                WidgetError(
                    text: "Flipper is Busy",
                    image: "WidgetFlipperBusy",
                    onBack: onBack
                )
            case .cantConnect:
                WidgetError(
                    text: "Can’t Connect to Flipper",
                    image: "WidgetCantConnect",
                    onBack: onBack
                )
            case .notSynced:
                WidgetError(
                    text: "This Key is Not Synced",
                    image: "WidgetKeyNotSynced",
                    onBack: onBack
                )
            case .bluetoothOff:
                WidgetError(
                    text: "iPhone’s Bluetooth is Turned Off",
                    image: "WidgetBTTurnedOff",
                    onBack: onBack
                )
            }
        }
        .padding(.vertical, 14)
    }
}
