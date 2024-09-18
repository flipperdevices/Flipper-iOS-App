import SwiftUI

struct DetectReaderCard: View {
    let hasNotification: Bool

    var body: some View {
        HubCard(
            icon: "nfc",
            title: "MIFARE Classic",
            image: "DetectReader",
            subtitle: "Mfkey32 (Detect Reader)",
            description: "Calculate keys from Detect Reader"
        ) {
            Badge()
                .opacity(hasNotification ? 1 : 0)
        }
    }

    struct Badge: View {
        var body: some View {
            Circle()
                .frame(width: 16, height: 16)
                .foregroundColor(.white)
                .overlay(alignment: .center) {
                    Circle()
                        .frame(width: 14, height: 14)
                        .foregroundColor(.sGreenUpdate)
                }
        }
    }
}
