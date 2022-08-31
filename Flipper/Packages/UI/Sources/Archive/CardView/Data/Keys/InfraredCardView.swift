import Core
import SwiftUI

struct InfraredCardView: View {
    @Binding var item: ArchiveItem
    let isEditing: Bool
    @Binding var focusedField: String

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            PropertyView(name: "Key Type:", value: item.type)
            PropertyView(name: "Protocol:", value: item.proto)
            PropertyView(name: "Address:", value: item.address)
            PropertyView(name: "Command:", value: item.command)
            PropertyView(name: "Data:", value: item.data)
                .opacity(item.data.isEmpty ? 0 : 1)
        }
    }
}

fileprivate extension ArchiveItem {
    var name: String { properties["name"] ?? "" }
    var type: String { properties["type"] ?? "" }
    var proto: String { properties["protocol"] ?? "" }
    var address: String { properties["address"] ?? "" }
    var command: String { properties["command"] ?? "" }

    var data: String { properties["data"] ?? "" }
}
