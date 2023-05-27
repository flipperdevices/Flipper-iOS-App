import Core
import SwiftUI

extension DetectReaderView {
    struct DuplicatedKeys: View {
        let flipperKeys: Set<MFKey64>
        let userKeys: Set<MFKey64>

        private var _flipperKeys: [MFKey64] { .init(flipperKeys) }
        private var _userKeys: [MFKey64] { .init(userKeys) }
        private var _count: Int { _flipperKeys.count + _userKeys.count }

        var body: some View {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 4) {
                    Text("Duplicated")

                    Text("(\(_count))")

                    Spacer()
                }
                .font(.system(size: 14, weight: .bold, design: .monospaced))

                VStack(alignment: .leading, spacing: 8) {
                    ForEach(_flipperKeys, id: \.self) { key in
                        HStack(spacing: 4) {
                            Text(key.hexValue.uppercased())

                            Text("(Found in Flipper Dict.)")
                                .foregroundColor(.black30)

                            Spacer()
                        }
                    }
                    ForEach(_userKeys, id: \.self) { key in
                        HStack(spacing: 4) {
                            Text(key.hexValue.uppercased())

                            Text("(Found in User Dict.)")
                                .foregroundColor(.black30)

                            Spacer()
                        }
                    }
                }
                .font(.system(size: 12, weight: .medium, design: .monospaced))
            }
        }
    }
}
