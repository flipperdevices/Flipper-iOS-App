import Core
import SwiftUI

struct IButtonCardView: View {
    @Binding var item: ArchiveItem
    @Binding var isEditMode: Bool
    @Binding var focusedField: String

    let flipped: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("HEX: \(item.key)")
                .font(.system(size: 18, weight: .bold))
                .lineLimit(1)

            Text(item.type)
                .font(.system(size: 16, weight: .medium))
        }
        .padding(.top, 16)
        .padding(.bottom, 4)
        .padding(.horizontal, 16)
        .opacity(flipped ? 0 : 1)
    }
}

fileprivate extension ArchiveItem {
    var key: String { self["Data"] ?? "" }
    var type: String { self["Key type"] ?? "" }
}
