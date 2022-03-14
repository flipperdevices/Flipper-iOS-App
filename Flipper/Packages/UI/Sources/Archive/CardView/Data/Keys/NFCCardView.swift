import Core
import SwiftUI

struct NFCCardView: View {
    @Binding var item: ArchiveItem
    let isEditing: Bool
    @Binding var focusedField: String

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            PropertyView(name: "Device Type:", value: item.type)
            PropertyView(name: "UID:", value: item.uid)
            PropertyView(name: "ATQA:", value: item.atqa)
            PropertyView(name: "SAK:", value: item.sak)
        }
    }
}

fileprivate extension ArchiveItem {
    var type: String { self["Device type"] ?? "" }
    var uid: String { self["UID"] ?? "" }
    var atqa: String { self["ATQA"] ?? "" }
    var sak: String { self["SAK"] ?? "" }

    // bank card
    var aid: String { self["AID"] ?? "" }
    var name: String { self["Name"] ?? "" }
    var number: String { self["Number"] ?? "" }
    var expData: String { self["Exp data"] ?? "" }
    var countryCode: String { self["Country code"] ?? "" }
}
