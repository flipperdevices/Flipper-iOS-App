import SwiftUI

// TODO: move to view builder

struct AlertButtons: View {
    @Binding var isPresented: Bool
    let text: String
    let cancel: String
    let isDestructive: Bool
    let action: () -> Void

    var actionColor: Color {
        isDestructive ? .sRed : .a2
    }

    @Environment(\.colorScheme) var colorScheme

    var dividerColor: Color {
        colorScheme == .light
            ? .black4
            : .black60
    }

    init(
        isPresented: Binding<Bool>,
        text: String,
        cancel: String,
        isDestructive: Bool = false,
        action: @escaping () -> Void
    ) {
        self._isPresented = isPresented
        self.text = text
        self.cancel = cancel
        self.isDestructive = isDestructive
        self.action = action
    }

    var body: some View {
        VStack(spacing: 14) {
            Divider()
                .background(dividerColor)

            Button {
                action()
                isPresented = false
            } label: {
                Text(text)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(actionColor)
                    .frame(maxWidth: .infinity)
            }

            Divider()
                .background(dividerColor)

            Button {
                isPresented = false
            } label: {
                Text(cancel)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity)
            }
        }
    }
}
