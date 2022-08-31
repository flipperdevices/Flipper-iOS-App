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
    var type: String { properties["Device type"] ?? "" }
    var uid: String { properties["UID"] ?? "" }
    var atqa: String { properties["ATQA"] ?? "" }
    var sak: String { properties["SAK"] ?? "" }

    // bank card
    var aid: String { properties["AID"] ?? "" }
    var name: String { properties["Name"] ?? "" }
    var number: String { properties["Number"] ?? "" }
    var expData: String { properties["Exp data"] ?? "" }
    var countryCode: String { properties["Country code"] ?? "" }
}
