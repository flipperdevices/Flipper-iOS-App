import Core
import SwiftUI

struct InfraredCardView: View {
    @Binding var item: ArchiveItem
    @Binding var isEditMode: Bool
    @Binding var focusedField: String

    let flipped: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !flipped {
                HStack {
                    Text("Name: \(item.name)")
                }
                .font(.system(size: 18, weight: .bold))

                HStack {
                    Text("Type: \(item.type)")
                    Spacer()
                }

                HStack {
                    Text("Protocol: \(item.proto)")
                    Spacer()
                }

                HStack {
                    Text("Address: \(item.address)")
                    Spacer()
                }

                HStack {
                    Text("Command: \(item.command)")
                    Spacer()
                }
            } else {
                HStack {
                    Text("Data: \(item.data)")
                    Spacer()
                }
                .opacity(item.data.isEmpty ? 0 : 1)
            }
        }
        .padding(.top, 16)
        .padding(.bottom, 4)
        .padding(.horizontal, 16)
        .opacity(flipped ? 0 : 1)
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
