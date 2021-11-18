import SwiftUI

struct RoundedButton: View {
    let text: String
    let isDanger: Bool
    let action: @MainActor () -> Void

    init(_ text: String, isDanger: Bool = false, action: @escaping @MainActor () -> Void) {
        self.text = text
        self.isDanger = isDanger
        self.action = action
    }

    var body: some View {
        Button {
            action()
        } label: {
            Text(text)
                .fontWeight(.semibold)
                .padding(14)
                .frame(maxWidth: .infinity)
                .background(isDanger ? Color.red : Color.accentColor)
                .foregroundColor(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(.horizontal, 15)
    }
}
