import SwiftUI

struct SettingsAddKeyView: View {
    var action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            VStack(spacing: 8) {
                Image(systemName: "plus.circle.fill")
                    .resizable()
                    .foregroundColor(.black4)
                    .frame(width: 38, height: 38)

                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.black4)
                    .frame(height: 45)
            }
        }
    }
}
