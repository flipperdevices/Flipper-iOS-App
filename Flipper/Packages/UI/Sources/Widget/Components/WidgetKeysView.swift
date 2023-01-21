import Core
import SwiftUI
import NotificationCenter

struct WidgetKeysView: View {
    @EnvironmentObject var widget: WidgetService

    var rows: Range<Int> {
        widget.isExpanded
            ? (0..<(keys.count / 2 + 1))
            : (0..<1)
    }

    var keys: [WidgetKey] {
        widget.keys
    }

    var body: some View {
        ForEach(rows, id: \.self) { row in
            HStack(spacing: 0) {
                let i1 = row * 2
                let i2 = i1 + 1

                ZStack {
                    if i1 < keys.count {
                        WidgetKeyView(key: keys[i1])
                    } else {
                        AddKeyButton()
                    }
                }
                .padding(.horizontal, 11)
                .padding(.bottom, 4)

                Divider()

                ZStack {
                    if i2 < keys.count {
                        WidgetKeyView(key: keys[i2])
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
}
