import SwiftUI

struct WidgetEmulateButton: View {
    let state: WidgetKeyState
    let onTapGesture: () -> Void
    let onLongPressGesture: () -> Void

    var color: Color {
        state == .disabled ? .black8 : .a2
    }

    var label: String {
        state == .emulating ? "Emulating..." : "Emulate"
    }

    var body: some View {
        HStack {
            Spacer()
            Text(label)
                .font(.born2bSportyV2(size: 22))
                .foregroundColor(.white)
            Spacer()
        }
        .frame(height: 45)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color)
        )
        .simultaneousGesture(LongPressGesture().onEnded { _ in
            onLongPressGesture()
        })
        .simultaneousGesture(TapGesture().onEnded {
            onTapGesture()
        })
        .disabled(state == .disabled)
    }
}

