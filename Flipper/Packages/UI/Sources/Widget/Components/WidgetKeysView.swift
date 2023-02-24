import Core
import SwiftUI
import NotificationCenter

struct WidgetKeysView: View {
    let keys: [WidgetKey]
    let isExpanded: Bool

    private let maxRows = 4
    private var keysRows: Int { keys.count / 2 + 1 }
    private var rowsCount: Int { isExpanded ? min(keysRows, maxRows) : 1 }
    private var rowsRange: Range<Int> { (0..<rowsCount) }

    var body: some View {
        VStack(spacing: 0) {
            ForEach(rowsRange, id: \.self) { row in
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

                if row + 1 < rowsRange.endIndex {
                    Divider()
                }
            }

            if keys.count >= maxRows * 2 {
                Divider()
                CustomizeButton()
                    .padding(.vertical, 6)
            }
        }
    }

    struct CustomizeButton: View {
        @Environment(\.openURL) var openURL

        var body: some View {
            Button {
                openURL(.todayWidgetSettings)
            } label: {
                Text("Customize")
                    .foregroundColor(.black30)
                    .font(.system(size: 12, weight: .medium))
            }
        }
    }
}
