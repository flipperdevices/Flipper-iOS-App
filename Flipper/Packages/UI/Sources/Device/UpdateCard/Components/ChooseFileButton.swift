import Core
import SwiftUI

struct ChooseFileButton: View {
    var action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            HStack {
                Spacer()
                Text("CHOOSE FILE")
                    .foregroundColor(.white)
                    .font(.born2bSportyV2(size: 40))
                Spacer()
            }
            .frame(height: 46)
            .frame(maxWidth: .infinity)
            .background(Color.a1)
            .cornerRadius(9)
            .padding(.horizontal, 12)
            .padding(.top, 12)
        }
    }
}
