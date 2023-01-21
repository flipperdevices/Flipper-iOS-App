import Core
import SwiftUI

extension EmulateView {
    struct EmulateDescription: View {
        let item: ArchiveItem
        let status: Device.Status
        let isEmulating: Bool

        var text: String {
            switch status {
            case .connected, .synchronized:
                guard item.status == .synchronized else {
                    return "Not synced. Unable to send from Flipper."
                }
                return item.kind == .subghz ? sendText : emulateText
            case .connecting:
                return "Connecting..."
            case .synchronizing:
                return "Syncing..."
            default:
                print(status)
                return "Flipper Not Connected"
            }
        }

        var sendText: String {
            if isEmulating {
                return ""
            } else {
                return "Hold to send from Flipper"
            }
        }

        var emulateText: String {
            if isEmulating {
                return "Emulating on Flipper... Tap to stop"
            } else {
                return ""
            }
        }

        var image: String {
            "WarningSmall"
        }

        var isError: Bool {
            (item.status != .synchronized) ||
            (status != .connected &&
             status != .connecting &&
             status != .synchronized &&
             status != .synchronizing)
        }

        var body: some View {
            HStack(spacing: 4) {
                if isError {
                    Image(image)
                }

                Text(text)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.black20)
            }
        }
    }
}
