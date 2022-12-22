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

private extension ArchiveItem {
    var props: [Property] {
        shadowCopy.isEmpty
            ? self.properties
            : self.shadowCopy
    }

    var type: String { props["Device type"] ?? "" }
    var uid: String { props["UID"] ?? "" }
    var atqa: String { props["ATQA"] ?? "" }
    var sak: String { props["SAK"] ?? "" }

    // bank card
    var aid: String { props["AID"] ?? "" }
    var name: String { props["Name"] ?? "" }
    var number: String { props["Number"] ?? "" }
    var expData: String { props["Exp data"] ?? "" }
    var countryCode: String { props["Country code"] ?? "" }
}
