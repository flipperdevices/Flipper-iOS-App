import SwiftUI

struct SendButton: View {
    let isEmulating: Bool

    var body: some View {
        ZStack {
            HStack {
                Spacer()
                Text(isEmulating ? "Sending..." : "Send")
                    .font(.born2bSportyV2(size: 23))
                Spacer()
            }
        }
        .frame(height: 48)
        .frame(maxWidth: .infinity)
        .foregroundColor(.white)
        .background(isEmulating ? .sending : .a1)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(.sendingBorder, lineWidth: 4)
                .opacity(isEmulating ? 1 : 0)
        }
    }
}
