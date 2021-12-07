import Core
import SwiftUI

struct NFCCardView: View {
    @Binding var item: ArchiveItem
    @Binding var isEditMode: Bool
    @Binding var focusedField: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            Text(item.type)

            HStack {
                Text("UID: \(item.uid)")
            }
            .font(.system(size: 18, weight: .bold))

            HStack {
                Text("ATQA: \(item.atqa)")
                Spacer()
                Text("SAK: \(item.atqa)")
            }
        }
        .font(.system(size: 16, weight: .medium))
        .padding(.top, 16)
        .padding(.bottom, 4)
        .padding(.horizontal, 16)
    }
}

fileprivate extension ArchiveItem {
    var type: String { self["Device type"] ?? "" }
    var uid: String { self["UID"] ?? "" }
    var atqa: String { self["ATQA"] ?? "" }
    var sak: String { self["SAK"] ?? "" }
}
