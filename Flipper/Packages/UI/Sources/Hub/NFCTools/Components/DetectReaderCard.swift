import SwiftUI

struct DetectReaderCard: View {
    let hasNotification: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                SmallImage("nfc")
                    .foregroundColor(.primary)

                Text("MIFARE Classic")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
            }

            HStack(spacing: 8) {
                Image("DetectReader")

                VStack(alignment: .leading, spacing: 2) {
                    Text("Mfkey32 (Detect Reader)")
                        .font(.system(size: 14, weight: .medium))
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.primary)

                    HStack {
                        Text("Calculate keys from Detect Reader")
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
        }
        .padding([.bottom, .leading, .top], 12)
        .padding(.trailing, 8)
        .background(Color.groupedBackground)
        .cornerRadius(10)
    }
}
