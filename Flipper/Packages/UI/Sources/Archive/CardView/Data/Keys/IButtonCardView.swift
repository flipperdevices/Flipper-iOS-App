import Core
import SwiftUI

struct IButtonCardView: View {
    @Binding var item: ArchiveItem
    let isEditing: Bool
    @Binding var focusedField: String

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            PropertyView(name: "Key Type:", value: item.type)
            PropertyView(name: "HEX:", value: item.key)
        }
    }
}

fileprivate extension ArchiveItem {
    var key: String { self["Data"] ?? "" }
    var type: String { self["Key type"] ?? "" }
}
