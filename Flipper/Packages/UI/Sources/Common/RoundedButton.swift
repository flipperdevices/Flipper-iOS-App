import SwiftUI

struct RoundedButton: View {
    let text: String
    let isDanger: Bool
    let action: @MainActor () -> Void

    init(
        _ text: String,
        isDanger: Bool = false,
        action: @escaping @MainActor () -> Void
    ) {
        self.text = text
        self.isDanger = isDanger
        self.action = action
    }

    var body: some View {
        Button {
            action()
        } label: {
            Text(text)
                .frame(height: 41)
                .padding(.horizontal, 38)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .background(isDanger ? Color.sRed : .a2)
                .cornerRadius(30)
        }
    }
}
