import SwiftUI

struct EmulateButton: View {
    let isEmulating: Bool

    var body: some View {
        ZStack {
            HStack {
                Spacer()
                Text(isEmulating ? "Emulating..." : "Emulate")
                    .font(.born2bSportyV2(size: 23))
                Spacer()
            }
        }
        .frame(height: 48)
        .frame(maxWidth: .infinity)
        .foregroundColor(.white)
        .background(isEmulating ? .emulating : .a2)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(.emulatingBorder, lineWidth: 4)
                .opacity(isEmulating ? 1 : 0)
        }
    }
}
