import Core
import SwiftUI

extension DetectReaderView {
    struct KeysView: View {
        let keys: [MFKey64]

        var rows: Range<Int> {
            0 ..< ((keys.count + 1) / 2)
        }

        init(_ keys: [MFKey64]) {
            self.keys = keys
        }

        var body: some View {
            VStack(spacing: 10) {
                ForEach(rows, id: \.self) { row in
                    HStack {
                        if keys.indices.contains(row * 2 + 1) {
                            KeyView(keys[row * 2])
                            Spacer()
                            KeyView(keys[row * 2 + 1])
                        } else {
                            Spacer()
                            KeyView(keys[row * 2])
                            Spacer()
                        }
                    }
                }
            }
        }
    }
}

