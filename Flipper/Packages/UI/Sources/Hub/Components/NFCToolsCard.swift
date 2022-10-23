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

                    Spacer()

                    Circle()
                        .frame(width: 16, height: 16)
                        .foregroundColor(.a1)
                        .opacity(hasNotification ? 1 : 0)

                    Image("ChevronRight")
                }
            }
        }
        .padding([.bottom, .leading, .top], 12)
        .padding(.trailing, 8)
        .background(Color.groupedBackground)
        .cornerRadius(10)
    }
}
