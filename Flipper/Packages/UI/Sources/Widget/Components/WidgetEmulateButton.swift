import SwiftUI

struct WidgetEmulateButton: View {
    let isEmulating: Bool
    let onTapGesture: () -> Void
    let onLongPressGesture: () -> Void

    @Environment(\.isEnabled) var isEnabled

    var color: Color {
        isEnabled ? .a2 : .black8
    }

    var label: String {
        isEmulating ? "Emulating..." : "Emulate"
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
    }
}
