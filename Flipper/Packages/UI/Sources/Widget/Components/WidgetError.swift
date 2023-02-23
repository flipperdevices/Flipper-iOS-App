import Core
import SwiftUI

extension WidgetView {
    struct WidgetError: View {
        let error: TodayWidget.Error
        let onDismiss: () -> Void

        @Environment(\.openURL) var openURL

        init(_ error: TodayWidget.Error, onDismiss: @escaping () -> Void) {
            self.error = error
            self.onDismiss = onDismiss
        }

        var text: String {
            switch error {
            case .appLocked: return "Flipper is Busy"
            case .notSynced: return "This Key is Not Synced"
            case .cantConnect: return "Can’t Connect to Flipper"
            case .bluetoothOff: return "iPhone’s Bluetooth is Turned Off"
            }
        }

        var image: String {
            switch error {
            case .appLocked: return "WidgetFlipperBusy"
            case .notSynced: return "WidgetKeyNotSynced"
            case .cantConnect: return "WidgetCantConnect"
            case .bluetoothOff: return "WidgetBTTurnedOff"
            }
        }

        var body: some View {
            VStack(spacing: 14) {
                VStack(spacing: 2) {
                    Image(image)
                    Text(text)
                        .font(.system(size: 14, weight: .medium))
                }

                HStack {
                    Spacer()

                    Button {
                        onDismiss()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.backward")
                                .font(.system(size: 14, weight: .medium))
                            Text("Back")
                                .font(.system(size: 14, weight: .medium))
                        }
                    }
                    .foregroundColor(.black60)

                    Spacer()
                    Spacer()

                    Button {
                        openURL(.flipperMobile)
                    } label: {
                        Text("Open App")
                            .font(.system(size: 14, weight: .medium))
                    }

                    Spacer()
                }

                Spacer()
            }
        }
    }
}
