import SwiftUI

struct AddKeyView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "plus.circle.fill")
                .resizable()
                .foregroundColor(.black4)
                .opacity(0.3)
                .frame(width: 38, height: 38)

            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black4)
                .opacity(0.3)
                .frame(height: 45)
        }
    }
}
