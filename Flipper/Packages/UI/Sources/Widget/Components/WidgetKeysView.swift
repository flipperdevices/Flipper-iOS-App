import Core
import SwiftUI
import NotificationCenter

struct WidgetKeysView: View {
    let keys: [WidgetKey]
    let isExpanded: Bool

    var rows: Range<Int> {
        isExpanded
            ? (0..<(keys.count / 2 + 1))
            : (0..<1)
    }

    var body: some View {
        VStack(spacing: 0) {
            ForEach(rows, id: \.self) { row in
                ZStack {
                    HStack {
                        Spacer()
                        Divider()
                        Spacer()
                    }

                    HStack(spacing: 0) {
                        let i1 = row * 2
                        let i2 = i1 + 1

                        Group {
                            if i1 < keys.count {
                                WidgetKeyView(key: keys[i1])
                            } else {
                                AddKeyButton()
                            }
                        }
                        .padding(10)

                        Group {
                            if i2 < keys.count {
                                WidgetKeyView(key: keys[i2])
                            } else {
                                AddKeyButton()
                                    .opacity(i1 < keys.count ? 1 : 0)
                            }
                        }
                        .padding(10)
                    }
                }

                if row + 1 < rows.endIndex {
                    Divider()
                }
            }
        }
    }
}
