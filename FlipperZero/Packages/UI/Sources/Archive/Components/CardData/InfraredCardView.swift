import Core
import SwiftUI

struct InfraredCardView: View {
    @Binding var item: ArchiveItem
    @Binding var isEditMode: Bool
    @Binding var focusedField: String

    let flipped: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(item.dump)
        }
        .padding(.top, 16)
        .padding(.bottom, 4)
        .padding(.horizontal, 16)
        .opacity(flipped ? 0 : 1)
    }
}

fileprivate extension ArchiveItem {
    var dump: String {
        var result = ""
        for property in properties {
            result += property.key
            result += ":"
            result += property.value
            result += "\n"
        }
        return result
    }
}
