import Core
import SwiftUI

extension ReaderAttackView {
    struct UniqueKeys: View {
        let keys: Set<MFKey64>

        private var _keys: [MFKey64] { .init(keys) }

        var body: some View {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 4) {
                    Text("Unique")

                    Text("(\(keys.count))")

                    Spacer()
                }
                .font(.system(size: 14, weight: .bold, design: .monospaced))

                VStack(alignment: .leading, spacing: 8) {
                    ForEach(_keys, id: \.self) { key in
                        Text(key.hexValue.uppercased())
                    }
                }
                .font(.system(size: 12, weight: .medium, design: .monospaced))
            }
        }
    }
}
