import Core
import SwiftUI

struct SUBGHZCardView: View {
    @Binding var item: ArchiveItem

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            PropertyView(name: "Protocol:", value: item.proto)
            PropertyView(
                name: "Key:",
                value: item.isRaw ? "Raw Data" : item.key
            )
        }
    }
}

fileprivate extension ArchiveItem {
    var key: String { properties["Key"] ?? "" }
    var proto: String { properties["Protocol"] ?? "" }
}
