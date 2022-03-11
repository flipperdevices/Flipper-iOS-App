import SwiftUI

struct RoundedButton: View {
    let text: String
    let action: () -> Void

    init(_ text: String, action: @escaping () -> Void) {
        self.text = text
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(text)
                .frame(height: 41)
                .padding(.horizontal, 38)
                .foregroundColor(.white)
                .background(Color.accentColor)
                .font(.system(size: 14, weight: .bold))
                .cornerRadius(30)
        }
    }
}

// TODO: remove

struct ObsoleteRoundedButton: View {
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
