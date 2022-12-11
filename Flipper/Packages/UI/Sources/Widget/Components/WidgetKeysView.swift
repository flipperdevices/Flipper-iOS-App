import Core
import SwiftUI

struct WidgetKeysView: View {
    let keys: [WidgetKey]
    let keyToEmulate: WidgetKey?
    let isExpanded: Bool

    var onSendPressed: (WidgetKey) -> Void
    var onSendReleased: (WidgetKey) -> Void
    var onEmulateTapped: (WidgetKey) -> Void

    var rows: Range<Int> {
        isExpanded
            ? (0..<(keys.count / 2 + 1))
            : (0..<1)
    }

    var body: some View {
        ForEach(rows, id: \.self) { row in
            HStack(spacing: 0) {
                let i1 = row * 2
                let i2 = i1 + 1

                ZStack {
                    if i1 < keys.count {
                        WidgetKeyView(
                            key: keys[i1],
                            state: state(for: keys[i1]),
                            onSendPressed: { onSendPressed(keys[i1]) },
                            onSendReleased: { onSendReleased(keys[i1]) },
                            onEmulateTapped: { onEmulateTapped(keys[i1]) }
                        )
                    } else {
                        AddKeyButton()
                    }
                }
                .padding(.horizontal, 11)
                .padding(.bottom, 4)

                Divider()

                ZStack {
                    if i2 < keys.count {
                        WidgetKeyView(
                            key: keys[i2],
                            state: state(for: keys[i1]),
                            onSendPressed: { onSendPressed(keys[i2]) },
                            onSendReleased: { onSendReleased(keys[i2]) },
                            onEmulateTapped: { onEmulateTapped(keys[i2]) }
                        )
                    } else {
                        AddKeyButton()
                            .opacity(i1 < keys.count ? 1 : 0)
                    }
                }
                .padding(.horizontal, 11)
                .padding(.bottom, 4)
            }

            if row + 1 < rows.endIndex {
                Divider()
            }
        }
    }

    func state(for key: WidgetKey) -> WidgetKeyState {
        guard let keyToEmulate = keyToEmulate else {
            return .idle
        }
        return key == keyToEmulate ? .emulating : .disabled
    }
}
