import SwiftUI

struct NFCToolsCard: View {
    let hasNotification: Bool

    var body: some View {
        HubCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    HStack(spacing: 12) {
                        Image("nfc")
                            .resizable()
                            .renderingMode(.template)
                            .frame(width: 30, height: 30)
                            .foregroundColor(.primary)

                        Text("NFC Tools")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.primary)
                    }

                    Spacer(minLength: 8)

                    HStack(spacing: 2) {
                        Circle()
                            .frame(width: 14, height: 14)
                            .foregroundColor(.a1)
                            .opacity(hasNotification ? 1 : 0)

                        Image("ChevronRight")
                            .resizable()
                            .frame(width: 14, height: 14)
                    }
                }

                Text("Calculate MIFARE Classic card keys using Flipper Zero")
                    .font(.system(size: 14, weight: .medium))
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.black30)
            }
        }
    }
}
