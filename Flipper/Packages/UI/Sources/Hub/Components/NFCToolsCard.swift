import SwiftUI

struct NFCToolsCard: View {
    let hasNotification: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Image("nfc")
                .resizable()
                .renderingMode(.template)
                .frame(width: 30, height: 30)
                .foregroundColor(.primary)

            VStack(alignment: .leading, spacing: 4) {
                Text("NFC Tools")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
                HStack {
                    Text(
                        "Calculate MIFARE Classic card keys using Flipper Zero"
                    )
                    .font(.system(size: 12, weight: .medium))
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.black30)

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
            }
        }
        .padding([.bottom, .leading, .top], 12)
        .padding(.trailing, 8)
        .background(Color.groupedBackground)
        .cornerRadius(10)
    }
}
