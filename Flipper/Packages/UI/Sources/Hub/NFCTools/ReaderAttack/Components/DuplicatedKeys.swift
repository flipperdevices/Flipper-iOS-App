import Core
import SwiftUI

extension ReaderAttackView {
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
                        .font(.system(size: 16, weight: .bold))

                    Text("(\(_count))")
                        .font(.system(size: 16, weight: .bold))

                    Spacer()
                }

                VStack(alignment: .leading, spacing: 8) {
                    ForEach(_flipperKeys, id: \.self) { key in
                        HStack(spacing: 4) {
                            Text(key.hexValue)
                                .font(.system(size: 12, weight: .medium))

                            Text("(Found in Flipper Dict.)")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.black30)

                            Spacer()
                        }
                    }
                    ForEach(_userKeys, id: \.self) { key in
                        HStack(spacing: 4) {
                            Text(key.hexValue)
                                .font(.system(size: 12, weight: .medium))

                            Text("(Found in User Dict.)")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.black30)

                            Spacer()
                        }
                    }
                }
            }
        }
    }
}
