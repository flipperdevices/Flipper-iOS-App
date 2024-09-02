import SwiftUI

struct InfraredSquareButton<Content: View>: View {
    @Environment(\.layoutScaleFactor) private var scaleFactor
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.layoutState) private var state

    let forceColor: Color?
    @ViewBuilder var content: () -> Content

    init(
        forceColor: Color? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.forceColor = forceColor
        self.content = content
    }

    private var defaultColor: Color {
        switch colorScheme {
        case .light: Color.black60
        default: Color.black80
        }
    }

    private var disabledColor: Color {
        switch colorScheme {
        case .light: Color.black20
        default: Color.black88
        }
    }

    var body: some View {
        ZStack {
            switch state {
            case .default:
                RoundedRectangle(cornerRadius: 12 * scaleFactor)
                    .fill(forceColor ?? defaultColor)
            case .emulating, .syncing:
                AnimatedPlaceholder()
                    .cornerRadius(12 * scaleFactor)
            case .disabled, .notSupported:
                RoundedRectangle(cornerRadius: 12 * scaleFactor)
                    .fill(forceColor ?? disabledColor)
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
