import Core
import SwiftUI

struct RFIDCardView: View {
    @Binding var item: ArchiveItem

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            PropertyView(name: "Key Type:", value: item.keyType)
            PropertyView(name: "Data:", value: item.data)
        }
    }
}

fileprivate extension ArchiveItem {
    var data: String { properties["Data"] ?? "" }
    var keyType: String { properties["Key type"] ?? "" }
}
