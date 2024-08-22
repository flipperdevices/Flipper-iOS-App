import SwiftUI

struct InfraredSquareButton<Content: View>: View {
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

    var body: some View {
        switch state {
        case .default:
            InfraredSquareButtonDefault(
                color: color,
                content: content)
        case .emulating:
            InfraredSquareButtonEmulating(content: content)
        case .syncing:
            InfraredSquareButtonSyncing()
        case .disabled, .notSupported:
            InfraredSquareButtonDisabled(
                color: color,
                content: content)
        }
    }
}

fileprivate extension InfraredSquareButton {

    struct InfraredSquareButtonDefault: View {
        @Environment(\.layoutScaleFactor) private var scaleFactor

        let color: Color?
        @ViewBuilder var content: () -> Content

        var body: some View {
            RoundedRectangle(cornerRadius: 12 * scaleFactor)
                .fill(color ?? .black80)
                .overlay {
                    content()
                }
        }
    }

    struct InfraredSquareButtonEmulating: View {
        @Environment(\.layoutScaleFactor) private var scaleFactor
        @ViewBuilder var content: () -> Content

        var body: some View {
            AnimatedPlaceholder()
                .cornerRadius(12 * scaleFactor)
                .overlay {
                    content()
                        .disabled(true)
                }
        }
    }

    struct InfraredSquareButtonSyncing: View {
        @Environment(\.layoutScaleFactor) private var scaleFactor

        var body: some View {
            AnimatedPlaceholder()
                .cornerRadius(12 * scaleFactor)
        }
    }

    struct InfraredSquareButtonDisabled: View {
        @Environment(\.layoutScaleFactor) private var scaleFactor

        let color: Color?
        @Environment(\.colorScheme) private var colorScheme

        @ViewBuilder var content: () -> Content

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
            RoundedRectangle(cornerRadius: 12 * scaleFactor)
                .fill(disabledColor)
                .overlay {
                    content()
                        .disabled(true)
                }
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
