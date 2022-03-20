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
    var name: String { self["name"] ?? "" }
    var type: String { self["type"] ?? "" }
    var proto: String { self["protocol"] ?? "" }
    var address: String { self["address"] ?? "" }
    var command: String { self["command"] ?? "" }

    var data: String { self["data"] ?? "" }
}
