import SwiftUI

struct InfraredSquareButton<Content: View>: View {
    @Environment(\.layoutScaleFactor) private var scaleFactor
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.layoutState) private var state

    let color: Color?
    @ViewBuilder var content: () -> Content

    init(
        color: Color? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.color = color
        self.content = content
    }

    private var disabledColor: Color {
        return if let color {
            color.opacity(0.2)
        } else {
            switch colorScheme {
            case .light: Color.black80.opacity(0.2)
            default: Color.black40
            }
        }
    }

    var body: some View {
        ZStack {
            switch state {
            case .default:
                RoundedRectangle(cornerRadius: 12 * scaleFactor)
                    .fill(color ?? .black80)
            case .emulating, .syncing:
                AnimatedPlaceholder()
                    .cornerRadius(12 * scaleFactor)
            case .disabled, .notSupported:
                RoundedRectangle(cornerRadius: 12 * scaleFactor)
                    .fill(disabledColor)
            }

            content()
                .opacity(state == .syncing ? 0 : 1)
                .disabled(state == .disabled || state == .syncing)
        }
    }
}

#Preview("Default") {
    InfraredSquareButton {
        Text("Default")
            .foregroundColor(Color.white)
    }
    .frame(width: 100, height: 100)
}

#Preview("Emulating") {
    InfraredSquareButton {
        Text("Emulating")
            .foregroundColor(Color.white)
    }
    .frame(width: 100, height: 100)
    .environment(\.layoutState, .emulating)
}

#Preview("Syncing") {
    InfraredSquareButton {
        Text("Syncing")
            .foregroundColor(Color.white)
    }
    .frame(width: 100, height: 100)
    .environment(\.layoutState, .syncing)
}

#Preview("Disabled") {
    InfraredSquareButton {
        Text("Disabled")
            .foregroundColor(Color.white)
    }
    .frame(width: 100, height: 100)
    .environment(\.layoutState, .disabled)
}
