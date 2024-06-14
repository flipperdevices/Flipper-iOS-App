import SwiftUI

struct TemplateButton: View {
    var body: some View {
        ZStack {
            HStack {
                Spacer()
                Text("Emulate")
                    .font(.born2bSportyV2(size: 23))
                Spacer()
            }
        }
        .frame(height: 48)
        .frame(maxWidth: .infinity)
        .foregroundColor(.white)
        .background(.gray)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
